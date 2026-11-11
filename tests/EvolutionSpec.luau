-- Regression tests for EvolutionRules.
local EvolutionRules = require("../src/shared/EvolutionRules")
local EvolutionCatalog = require("../src/shared/EvolutionCatalog")

return function(test, eq)
    test("evolution requires minimum catches and coins", function()
        local data = { coins = 100, species = { breeze = 2 }, companionSpecies = "", companionBond = {} }
        local ok, reason = EvolutionRules.canEvolve(data, "breeze_to_gale")
        eq(ok, false, "insufficient catches")
        data.species.breeze = 3
        ok, reason = EvolutionRules.canEvolve(data, "breeze_to_gale")
        eq(ok, false, "insufficient coins")
        data.coins = 200
        ok, reason = EvolutionRules.canEvolve(data, "breeze_to_gale")
        eq(ok, true, "eligible")
    end)

    test("applyEvolution consumes source, adds target and pays cost", function()
        local data = { coins = 200, species = { breeze = 4 }, companionSpecies = "", companionBond = {} }
        local ok, path = EvolutionRules.applyEvolution(data, "breeze_to_gale")
        eq(ok, true, "applied")
        eq(data.species.breeze, 3, "source decremented")
        eq(data.species.gale, 1, "target added")
        eq(data.coins, 50, "cost paid")
    end)

    test("bond requirement blocks when companion not bonded enough", function()
        local data = { coins = 500, species = { mist = 5 }, companionSpecies = "mist", companionBond = { mist = 5 } }
        local ok = EvolutionRules.canEvolve(data, "mist_to_mistveil")
        eq(ok, false, "bond too low")
        data.companionBond.mist = 15
        ok = EvolutionRules.canEvolve(data, "mist_to_mistveil")
        eq(ok, true, "bond sufficient")
    end)
end

-- Unit tests for species mastery and evolution rules.
return function(test, eq)
    local Rules = require("../src/shared/EvolutionRules")
    local Catch = require("../src/shared/CatchRules")

    test("mastery accumulates on catch and evolution rewards once", function()
        local data = { species = {}, captures = 0, coins = 0, xp = 0, quests = {}, speciesMastery = {}, evolvedSpecies = {} }
        local quests = {}
        Catch.applyCatch(data, "breeze", 10, quests, { mastery = 10 })
        eq(data.speciesMastery.breeze, 10, "mastery awarded")
        eq(Rules.canEvolve("breeze", data.speciesMastery, "Common", data.evolvedSpecies), false, "not enough yet")
        data.speciesMastery.breeze = 40
        eq(Rules.canEvolve("breeze", data.speciesMastery, "Common", data.evolvedSpecies), true, "ready")
        eq(Rules.apply(data, "breeze", "Common"), true, "evolved")
        eq(data.evolvedSpecies.breeze, true, "flag set")
        eq(data.coins, 75, "coins awarded")
        eq(Rules.apply(data, "breeze", "Common"), false, "cannot evolve twice")
        eq(data.coins, 75, "no double reward")
    end)

    test("evolution rejects unknown rarity and malformed data", function()
        local data = { speciesMastery = { breeze = 1000 }, evolvedSpecies = {} }
        eq(Rules.apply(data, "breeze", "Unknown"), false, "unknown rarity threshold")
        eq(Rules.canEvolve("bad id", data.speciesMastery, "Common", data.evolvedSpecies), false, "invalid id")
        eq(Rules.apply({ speciesMastery = {}, evolvedSpecies = { breeze = true } }, "breeze", "Common"), false, "already evolved")
    end)
end

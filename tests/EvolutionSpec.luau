-- Regression tests for cloud evolution rules.
return function(test, eq)
    local EvolutionRules = require("../src/shared/EvolutionRules")
    local EvolutionCatalog = require("../src/shared/EvolutionCatalog")
    local CloudCatalog = {
        breeze = { name = "Breeze" }, gale = { name = "Gale" },
        drizzle = { name = "Drizzle" }, mist = { name = "Mist" },
        pebble = { name = "Pebble" }, crystal = { name = "Crystal" },
    }

    test("canEvolve rejects insufficient duplicates and unknown recipes", function()
        local data = { species = { breeze = 4 } }
        local ok, reason = EvolutionRules.canEvolve("breeze_to_gale", data, EvolutionCatalog, CloudCatalog)
        eq(ok, false, "not enough")
        eq(reason, "insufficient", "reason")
        eq(EvolutionRules.canEvolve("bogus", data, EvolutionCatalog, CloudCatalog), false, "unknown recipe")
    end)

    test("applyEvolve consumes required and grants evolved species", function()
        local data = { species = { breeze = 7, gale = 1 } }
        local ok, toSpecies = EvolutionRules.applyEvolve(data, "breeze_to_gale", EvolutionCatalog, CloudCatalog)
        eq(ok, true, "success")
        eq(toSpecies, "gale", "target")
        eq(data.species.breeze, 2, "consumed 5")
        eq(data.species.gale, 2, "gained 1")
    end)

    test("applyEvolve removes zeroed source and rejects second evolve without enough", function()
        local data = { species = { drizzle = 4 } }
        local ok = EvolutionRules.applyEvolve(data, "drizzle_to_mist", EvolutionCatalog, CloudCatalog)
        eq(ok, true, "first")
        eq(data.species.drizzle, nil, "zero removed")
        eq(data.species.mist, 1, "gained")
        local again = EvolutionRules.applyEvolve(data, "drizzle_to_mist", EvolutionCatalog, CloudCatalog)
        eq(again, false, "second fails")
    end)
end

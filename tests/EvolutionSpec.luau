-- Regression tests for EvolutionRules.
return function(test, eq)
    local Rules = require("../src/shared/EvolutionRules")
    local catalog = {
        breeze = { name = "Breeze" }, gale = { name = "Gale" },
        drizzle = { name = "Drizzle" }, monsoon = { name = "Monsoon" },
    }

    test("canEvolve rejects insufficient duplicates and coins", function()
        local data = { species = { breeze = 3 }, coins = 100 }
        local ok, reason = Rules.canEvolve("breeze", data, catalog)
        eq(ok, false, "not enough")
        eq(reason, "insufficient_species", "reason")

        data.species.breeze = 5
        data.coins = 10
        ok, reason = Rules.canEvolve("breeze", data, catalog)
        eq(ok, false, "poor")
        eq(reason, "insufficient_coins", "reason")
    end)

    test("applyEvolve consumes duplicates, spends coins and grants result species", function()
        local data = { species = { breeze = 6 }, coins = 100, xp = 0 }
        local ok, result, xp = Rules.applyEvolve("breeze", data, catalog)
        eq(ok, true, "success")
        eq(result, "gale", "result id")
        eq(xp, 20, "xp")
        eq(data.species.breeze, 1, "remaining")
        eq(data.species.gale, 1, "gained")
        eq(data.coins, 60, "coins spent")
        eq(data.xp, 20, "xp added")
    end)

    test("applyEvolve rejects unknown or non-evolvable species and invalid data", function()
        local data = { species = { breeze = 10 }, coins = 999 }
        local ok, reason = Rules.applyEvolve("unknown", data, catalog)
        eq(ok, false, "unknown")
        eq(reason, "no_evolution", "reason")
        ok = Rules.applyEvolve("breeze", nil, catalog)
        eq(ok, false, "nil data")
        ok = Rules.applyEvolve("breeze", data, nil)
        eq(ok, false, "nil catalog")
    end)
end

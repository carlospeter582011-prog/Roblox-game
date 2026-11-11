-- Regression tests for EvolutionRules. Requires the shared module.
return function(test, eq)
    local Rules = require("../src/shared/EvolutionRules")
    local catalog = {
        breeze = { name = "Breeze" }, gale = { name = "Gale" },
        drizzle = { name = "Drizzle" }, monsoon = { name = "Monsoon" },
        pebble = { name = "Pebble" }, geode = { name = "Geode" },
    }

    test("canEvolve rejects insufficient duplicates and coins", function()
        local counts = { breeze = 5 }
        eq(Rules.canEvolve("breeze", counts, 200, catalog), false, "need 6 to keep one")
        counts.breeze = 6
        eq(Rules.canEvolve("breeze", counts, 100, catalog), false, "need coins")
        local ok, path = Rules.canEvolve("breeze", counts, 200, catalog)
        eq(ok, true, "eligible")
        eq(path.into, "gale", "target")
        eq(Rules.canEvolve("unknown", counts, 999, catalog), false, "no path")
        eq(Rules.canEvolve("breeze", counts, 200, {}), false, "missing evolved in catalog")
    end)

    test("apply consumes duplicates, spends coins and grants evolved species", function()
        local data = { species = { breeze = 8, gale = 0 }, coins = 500 }
        local ok, into = Rules.apply("breeze", data, catalog)
        eq(ok, true, "applied")
        eq(into, "gale", "result")
        eq(data.species.breeze, 3, "duplicates consumed (kept 3)")
        eq(data.species.gale, 1, "evolved granted")
        eq(data.coins, 300, "coins spent")
        -- second evolve fails now
        eq(Rules.apply("breeze", data, catalog), false, "insufficient after")
    end)

    test("apply rejects malformed profiles and does not partially mutate", function()
        local bad = { species = { breeze = 10 }, coins = "many" }
        eq(Rules.apply("breeze", bad, catalog), false, "bad coins")
        eq(bad.species.breeze, 10, "unchanged")
        local data = { species = { drizzle = 10 }, coins = 1000 }
        eq(Rules.apply("drizzle", data, catalog), true, "drizzle path")
        eq(data.species.drizzle, 6, "consumed 4")
        eq(data.species.monsoon, 1, "granted")
    end)
end

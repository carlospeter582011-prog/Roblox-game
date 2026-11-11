-- Regression tests for CloudEvolutionRules. No Roblox globals.
local Rules = require("../src/shared/CloudEvolutionRules")
local Catalog = require("../src/shared/CloudCatalog")

return function(test, eq)
    test("evolution requires owned parent, coins and captures", function()
        local recipe = Rules.findRecipe("breeze_to_cirrus")
        local data = { species = { breeze = 2 }, coins = 100, captures = 10 }
        local ok, reason = Rules.canEvolve(data, recipe, Catalog)
        eq(ok, true, "eligible")
        eq(reason, nil, "no reason")

        data.species.breeze = 0
        ok, reason = Rules.canEvolve(data, recipe, Catalog)
        eq(ok, false, "no parent")
        eq(reason, "missing_parent", "reason")

        data.species.breeze = 1
        data.coins = 10
        ok, reason = Rules.canEvolve(data, recipe, Catalog)
        eq(ok, false, "poor")
        eq(reason, "insufficient_coins", "reason")

        data.coins = 100
        data.captures = 2
        ok, reason = Rules.canEvolve(data, recipe, Catalog)
        eq(ok, false, "few captures")
        eq(reason, "insufficient_captures", "reason")
    end)

    test("applyEvolution consumes parent, spends coins and grants result", function()
        local recipe = Rules.findRecipe("drizzle_to_mist")
        local data = { species = { drizzle = 1 }, coins = 50, captures = 5 }
        local ok, result = Rules.applyEvolution(data, recipe, Catalog)
        eq(ok, true, "evolved")
        eq(result, "mist", "result id")
        eq(data.species.drizzle, nil, "parent consumed")
        eq(data.species.mist, 1, "result granted")
        eq(data.coins, 15, "coins spent")
    end)

    test("unknown recipe and missing catalog species are rejected", function()
        local data = { species = { breeze = 5 }, coins = 999, captures = 20 }
        local ok, reason = Rules.canEvolve(data, { parent = "missing", result = "cirrus", coinCost = 1, minCaptures = 0 }, Catalog)
        eq(ok, false, "bad parent")
        eq(reason, "unknown_species", "reason")
        eq(Rules.findRecipe("nope"), nil, "unknown id")
    end)
end

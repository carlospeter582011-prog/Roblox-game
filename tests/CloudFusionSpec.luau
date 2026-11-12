return function(test, eq)
    local Rules = require("../src/shared/CloudFusionRules")
    local Catalog = require("../src/shared/CloudCatalog")
    test("fusion consumes spare clouds and coins, awards existing species", function()
        local data = { coins = 200, species = { breeze = 3, drizzle = 3 } }
        local ok, result = Rules.apply(data, "mist_weave", Catalog)
        eq(ok, true, "fused")
        eq(result, "mist", "output")
        eq(data.coins, 120, "cost")
        eq(data.species.breeze, 1, "protected breeze")
        eq(data.species.drizzle, 1, "protected drizzle")
        eq(data.species.mist, 1, "output count")
        eq(Rules.apply(data, "mist_weave", Catalog), false, "cannot repeat without ingredients")
    end)
    test("fusion rejects invalid input without changing inventory", function()
        local data = { coins = 200, species = { breeze = 2, drizzle = 3 } }
        eq(Rules.apply(data, "mist_weave", Catalog), false, "protect last copy")
        eq(data.coins, 200, "no cost")
        eq(data.species.breeze, 2, "no consumption")
        eq(Rules.apply(data, "unknown", Catalog), false, "unknown recipe")
        data.species.breeze = math.huge
        eq(Rules.apply(data, "mist_weave", Catalog), false, "infinite ingredient rejected")
        data.species.breeze = 3
        data.coins = 0 / 0
        eq(Rules.apply(data, "mist_weave", Catalog), false, "nan coins rejected")
    end)
    test("every fusion recipe references valid catalog species", function()
        for id, recipe in pairs(Rules.recipes) do
            eq(recipe.id, id, "stable recipe id")
            eq(Catalog[recipe.output] ~= nil, true, "known result")
            for ingredient, count in pairs(recipe.inputs) do
                eq(Catalog[ingredient] ~= nil, true, "known ingredient")
                eq(count > 0, true, "positive count")
            end
        end
    end)
end

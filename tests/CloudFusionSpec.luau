return function(test, eq)
    local Rules = require("../src/shared/CloudFusionRules")
    local Catalog = require("../src/shared/CloudCatalog")
    test("fusion spends Coins and one duplicate of each parent", function()
        local data = { coins = 100, species = { breeze = 3, drizzle = 2 } }
        local ok = Rules.apply(data, "mist_weave", Catalog)
        eq(ok, true, "fused")
        eq(data.species.breeze, 2, "first retained")
        eq(data.species.drizzle, 1, "second retained")
        eq(data.species.mist, 1, "output added")
        eq(data.coins, 40, "cost")
    end)
    test("fusion rejects invalid recipes, insufficient duplicates and insufficient Coins atomically", function()
        local data = { coins = 59, species = { breeze = 2, drizzle = 2 } }
        eq(Rules.apply(data, "mist_weave", Catalog), false, "price")
        eq(data.species.breeze, 2, "unchanged")
        eq(data.coins, 59, "unchanged coins")
        data.coins = 100
        data.species.breeze = 1
        eq(Rules.apply(data, "mist_weave", Catalog), false, "protected last copy")
        eq(Rules.apply(data, "unknown", Catalog), false, "invalid recipe")
        eq(data.coins, 100, "no debit")
    end)
    test("fusion rejects malformed counts and capped outputs", function()
        local data = { coins = 1000, species = { breeze = math.huge, drizzle = 2 } }
        eq(Rules.apply(data, "mist_weave", Catalog), false, "infinite parent")
        data.species.breeze = 2
        data.species.mist = 999999
        eq(Rules.apply(data, "mist_weave", Catalog), false, "output capped")
        eq(data.coins, 1000, "no debit")
    end)
end

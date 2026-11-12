return function(test, eq)
    local Rules = require("../src/shared/CloudFusionRules")
    local catalog = { breeze = {}, drizzle = {}, mist = {}, gale = {}, thunder = {}, stormfront = {}, ember = {}, sunbeam = {}, solar = {} }
    test("fusion consumes only spare copies and exact Coins", function()
        local profile = { coins = 100, species = { breeze = 2, drizzle = 2 } }
        local ok, plan = Rules.apply(profile, "mistweave", catalog)
        eq(ok, true, "fused")
        eq(plan.result, "mist", "outcome")
        eq(profile.species.breeze, 1, "breeze preserved")
        eq(profile.species.drizzle, 1, "drizzle preserved")
        eq(profile.species.mist, 1, "result granted")
        eq(profile.coins, 20, "cost")
    end)
    test("fusion rejects insufficient stock, money and unknown recipe without mutation", function()
        local profile = { coins = 79, species = { breeze = 2, drizzle = 2 } }
        eq(select(1, Rules.apply(profile, "mistweave", catalog)), false, "wallet")
        eq(profile.coins, 79, "no deduction")
        profile.coins = 100
        profile.species.breeze = 1
        eq(select(1, Rules.apply(profile, "mistweave", catalog)), false, "last copy")
        eq(select(1, Rules.apply(profile, "bogus", catalog)), false, "unknown recipe")
        eq(profile.species.drizzle, 2, "stock intact")
    end)
    test("fusion refuses corrupt balances and caps", function()
        local profile = { coins = math.huge, species = { breeze = 2, drizzle = 2 } }
        eq(select(1, Rules.apply(profile, "mistweave", catalog)), false, "infinite wallet")
        profile.coins = 100
        profile.species.mist = 1000000
        eq(select(1, Rules.apply(profile, "mistweave", catalog)), false, "output cap")
        profile.species.mist = 0
        profile.species.drizzle = 0 / 0
        eq(select(1, Rules.apply(profile, "mistweave", catalog)), false, "nan inventory")
    end)
end

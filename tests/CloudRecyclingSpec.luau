return function(test, eq)
    local Rules = require("../src/shared/CloudRecyclingRules")
    local catalog = { breeze = { rarity = "Common" }, thunder = { rarity = "Rare" } }
    test("recycling duplicate awards currency without changing lifetime catches", function()
        local data = { coins = 5, xp = 7, captures = 9, species = { breeze = 3 } }
        local ok, reward = Rules.recycle(data, "breeze", catalog)
        eq(ok, true, "accepted")
        eq(reward.coins, 12, "coin payout")
        eq(data.coins, 17, "coins")
        eq(data.xp, 15, "xp")
        eq(data.species.breeze, 2, "preserve two")
        eq(data.captures, 9, "lifetime catches")
        eq(Rules.recycle(data, "breeze", catalog), false, "cannot recycle below reserve")
    end)
    test("recycling rejects invalid and fabricated species", function()
        local data = { coins = 0, xp = 0, species = { bogus = 999, thunder = 3 } }
        eq(Rules.recycle(data, "bogus", catalog), false, "unknown")
        eq(Rules.recycle(data, "thunder:golden", catalog), false, "mutation id")
        eq(Rules.recycle(data, {}, catalog), false, "type")
        eq(data.species.thunder, 3, "untouched")
    end)
    test("recycling respects wallet limits and malformed quantities", function()
        local data = { coins = 1e12 - 10, xp = 0, species = { thunder = 3 } }
        eq(Rules.recycle(data, "thunder", catalog), false, "limit")
        eq(data.species.thunder, 3, "no partial debit")
        data.coins = 0
        data.species.thunder = math.huge
        eq(Rules.recycle(data, "thunder", catalog), false, "infinite")
    end)
end

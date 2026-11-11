return function(test, eq)
    local Rules = require("../src/shared/DuplicateExchangeRules")
    local catalog = { breeze = { baseRewardCoins = 10 }, storm = { baseRewardCoins = 40 } }
    test("exchange keeps final copy and credits bounded coins", function()
        local p = { species = { breeze = 3, storm = 1 }, coins = 20 }
        local ok, id, reward = Rules.exchange(p, catalog)
        eq(ok, true, "success")
        eq(id, "breeze", "chosen")
        eq(reward, 5, "reward")
        eq(p.species.breeze, 2, "one consumed")
        eq(p.coins, 25, "credited")
        Rules.exchange(p, catalog)
        eq(p.species.breeze, 1, "last copy kept")
        eq(Rules.exchange(p, catalog), false, "no remaining duplicate")
    end)
    test("exchange rejects unknown, invalid and full-wallet states", function()
        eq(Rules.choose({ fake = 999, breeze = math.huge }, catalog), nil, "invalid counts")
        local p = { species = { storm = 2 }, coins = 1000000000 }
        eq(Rules.exchange(p, catalog), false, "wallet cap")
        eq(p.species.storm, 2, "no loss on failure")
        p.coins = 0
        eq(Rules.exchange(p, catalog), true, "valid trade")
        eq(p.coins, 20, "storm reward")
    end)
end

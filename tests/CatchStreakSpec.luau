return function(test, eq)
    local Rules = require("../src/shared/CatchStreakRules")
    test("streak starts without a free bonus", function()
        local n, coins = Rules.advance(nil, nil, 100)
        eq(n, 1, "new count")
        eq(coins, 0, "new bonus")
    end)
    test("five rapid catches reward exactly ten coins", function()
        local n, at = 0, nil
        for i = 1, 5 do
            local coins
            n, coins = Rules.advance(n, at, 100 + i)
            at = 100 + i
            eq(coins, i == 5 and 10 or 0, "milestone reward")
        end
        eq(n, 5, "streak")
    end)
    test("timeout and backwards time reset the streak", function()
        local n, bonus = Rules.advance(4, 100, 176)
        eq(n, 1, "timeout")
        eq(bonus, 0, "timeout bonus")
        eq(Rules.advance(4, 100, 99), 1, "backwards")
    end)
    test("streak caps rewards and rejects malformed timestamps", function()
        local n, bonus = Rules.advance(20, 100, 101)
        eq(n, 20, "cap")
        eq(bonus, 0, "no repeated cap bonus")
        eq(Rules.advance(4, 100, math.huge), 0, "infinite time")
        eq(Rules.advance(4, 100, 0/0), 0, "nan time")
    end)
end

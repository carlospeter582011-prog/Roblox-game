local Rules = require("../src/shared/CatchStreakRules")
return function(test, eq)
    test("catch streak pays only at exact milestones", function()
        local state = nil
        local totals = { coins = 0, xp = 0 }
        for n = 1, 13 do
            local coins, xp
            state, coins, xp = Rules.advance(state, n)
            eq(state.count, n, "count")
            totals.coins += coins
            totals.xp += xp
            if n ~= 3 and n ~= 7 and n ~= 12 then
                eq(coins, 0, "no duplicate milestone coins")
                eq(xp, 0, "no duplicate milestone xp")
            end
        end
        eq(totals.coins, 160, "total milestone coins")
        eq(totals.xp, 95, "total milestone xp")
    end)
    test("catch streak resets after window and ignores invalid timestamps", function()
        local state = { count = 11, at = 10 }
        local nextState, coins = Rules.advance(state, 56)
        eq(nextState.count, 1, "expired")
        eq(coins, 0, "no expired reward")
        nextState = Rules.advance({ count = 2, at = 10 }, 55)
        eq(nextState.count, 3, "inclusive window")
        nextState, coins = Rules.advance({ count = 11, at = 10 }, 0/0)
        eq(nextState.count, 0, "nan clock")
        eq(coins, 0, "nan reward")
        nextState = Rules.advance({ count = 11, at = 999 }, 12)
        eq(nextState.count, 1, "future timestamp rejected")
    end)
end

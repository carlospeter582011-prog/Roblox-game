return function(test, eq)
    local Rules = require("../src/shared/SkyBridgeRules")
    test("sky bridge requires exact sequence", function()
        local s
        for _, pad in ipairs({2,4,1}) do
            local result
            s, result = Rules.step(s, pad, 100)
            eq(result, "progress", "correct prefix")
        end
        local result
        s, result = Rules.step(s, 3, 105)
        eq(result, "unlocked", "unlock")
        eq(s.unlockedUntil, 180, "duration")
    end)
    test("sky bridge rejects wrong rune and retry spam", function()
        local s, result = Rules.step(nil, 1, 10)
        eq(result, "wrong", "wrong")
        s, result = Rules.step(s, 2, 11)
        eq(result, "wait", "cooldown")
        s, result = Rules.step(s, 2, 18)
        eq(result, "progress", "retry")
        s, result = Rules.step(s, 4, 54)
        eq(result, "wrong", "expired sequence")
    end)
    test("sky bridge rejects malformed pad and preserves open state", function()
        local s = {index=1, started=nil, unlockedUntil=200, retryAt=0}
        local nextState, result = Rules.step(s, 0, 100)
        eq(result, "invalid", "invalid id")
        eq(nextState, s, "no mutation")
        nextState, result = Rules.step(s, 2, 100)
        eq(result, "open", "already open")
        eq(nextState, s, "no extension")
    end)
end

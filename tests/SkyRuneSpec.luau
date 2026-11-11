local Rules = require("../src/shared/SkyRuneRules")
return function(test, eq)
    test("sky rune sequences are deterministic permutations", function()
        for id = 1, 12 do
            local sequence = Rules.sequence(id, 1)
            local seen = {}
            for _, rune in ipairs(sequence) do seen[rune] = true end
            eq(seen[1] and seen[2] and seen[3], true, "all runes appear")
            eq(#sequence, 3, "three runes")
            eq(Rules.sequence(id, 1)[1], sequence[1], "stable order")
        end
        eq(Rules.sequence(0, 1), nil, "invalid player")
    end)
    test("sky rune puzzle advances only in correct order", function()
        local sequence = { 2, 3, 1 }
        local status, step = Rules.advance(sequence, 1, 2, 100, 105)
        eq(status, "progress", "first")
        eq(step, 2, "next step")
        status, step = Rules.advance(sequence, 2, 1, 100, 106)
        eq(status, "wrong", "wrong order")
        eq(step, 1, "reset")
        status, step = Rules.advance(sequence, 3, 1, 100, 107)
        eq(status, "complete", "complete")
        eq(step, 4, "finished")
    end)
    test("sky rune puzzle rejects stale and invalid activations", function()
        local sequence = { 1, 2, 3 }
        eq(Rules.advance(sequence, 1, 1, 100, 141), "expired", "timeout")
        eq(Rules.advance(sequence, 1, 1, 100, 99), "expired", "clock regression")
        eq(Rules.advance(sequence, 1, 0, 100, 101), "expired", "invalid rune")
        eq(Rules.advance(sequence, 4, 1, 100, 101), "expired", "invalid step")
    end)
end

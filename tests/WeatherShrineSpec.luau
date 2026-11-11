local Rules = require("../src/shared/WeatherShrineRules")
return function(test, eq)
    test("weather shrine generates valid deterministic permutations", function()
        local seen = {}
        for i = 0, 5 do
            local s = Rules.sequence(i)
            local key = table.concat(s, "")
            eq(seen[key], nil, "unique sequence")
            seen[key] = true
            local used = {}
            for _, n in ipairs(s) do used[n] = true end
            eq(used[1] and used[2] and used[3], true, "all three runes")
        end
        eq(Rules.sequence(0/0), nil, "invalid seed")
    end)
    test("weather shrine validates sequence and completion", function()
        local s = {3,1,2}
        local ok, stage = Rules.advance(s, 1, 3, 10, 20)
        eq(ok, true, "first")
        eq(stage, 2, "next stage")
        ok, stage = Rules.advance(s, 2, 1, 10, 21)
        eq(stage, 3, "third")
        ok, stage = Rules.advance(s, 3, 2, 10, 22)
        eq(stage, "complete", "complete")
        eq(Rules.advance(s, 1, 1, 10, 20), false, "wrong rune")
        eq(Rules.advance(s, 1, 3, 10, 56), false, "expired")
        eq(Rules.advance(s, 1, 3, 10, 9), false, "reversed time")
    end)
    test("weather shrine enforces cooldown", function()
        eq(Rules.canStart(100, nil), true, "first")
        eq(Rules.canStart(279, 100), false, "too early")
        eq(Rules.canStart(280, 100), true, "ready")
        eq(Rules.canStart(0/0, nil), false, "NaN")
    end)
end

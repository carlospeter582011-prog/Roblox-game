return function(test, eq)
    local Combo = require("../src/shared/CatchComboRules")
    test("catch combo grows and caps bonus without coins", function()
        local state = nil
        for i = 1, 9 do
            state = Combo.preview(state, i * 2)
            eq(state.streak, math.min(i, 6), "streak")
            eq(state.bonusXP, math.min(i - 1, 5), "bonus")
        end
    end)
    test("catch combo expires after window and handles clock reversal", function()
        local start = Combo.preview(nil, 100)
        eq(Combo.preview(start, 125).streak, 2, "inclusive window")
        eq(Combo.preview(start, 125.01).streak, 1, "expired")
        eq(Combo.preview(start, 99).streak, 1, "reversed clock")
    end)
    test("catch combo rejects invalid time and corrupt previous state", function()
        eq(Combo.preview(nil, math.huge), nil, "invalid timestamp")
        eq(Combo.preview(nil, 0 / 0), nil, "nan timestamp")
        eq(Combo.preview({time = 3, streak = math.huge}, 4).streak, 1, "corrupt streak")
        eq(Combo.preview({time = 3, streak = 1.5}, 4).streak, 1, "fraction streak")
    end)
end

local Finesse = require("../src/shared/CatchFinesseRules")
return function(test, eq)
    test("finesse close chase earns bounded XP; normal distance earns none", function()
        eq(Finesse.bonus(3, 10), 8, "close boundary")
        eq(Finesse.bonus(6, 10), 4, "mid boundary")
        eq(Finesse.bonus(9, 10), 0, "far catch")
        eq(Finesse.bonus(3.01, 10), 4, "above close")
        eq(Finesse.bonus(6.01, 10), 0, "above mid")
        eq(Finesse.bonus(0, 10), Finesse.MAX_BONUS_XP, "maximum")
    end)
    test("finesse rejects invalid geometry and nonfinite values", function()
        for _, bad in ipairs({ -1, math.huge, 0/0, "3" }) do
            eq(Finesse.bonus(bad, 10), 0, "invalid distance")
        end
        for _, bad in ipairs({ -1, 0, math.huge, 0/0, "10" }) do
            eq(Finesse.bonus(2, bad), 0, "invalid radius")
        end
    end)
end

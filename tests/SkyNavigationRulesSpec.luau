return function(test, eq)
    local Rules = require("../src/shared/SkyNavigationRules")
    test("observatory compass completes only in correct order", function()
        local p = 0
        for i, d in ipairs({ "north", "east", "south", "west" }) do
            local done
            p, done = Rules.step(p, d, 10)
            eq(p, i, "progress")
            eq(done, i == 4, "completion")
        end
    end)
    test("observatory wrong directions reset progress", function()
        eq(select(1, Rules.step(2, "west", 10)), 0, "wrong step")
    end)
    test("observatory rejects expired, NaN and forged progress", function()
        eq(select(1, Rules.step(2, "south", 46)), 0, "timeout")
        eq(select(1, Rules.step(2, "south", 0/0)), 0, "NaN")
        eq(select(1, Rules.step(-1, "north", 1)), 0, "invalid progress")
    end)
end

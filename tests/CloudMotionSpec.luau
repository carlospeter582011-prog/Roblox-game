return function(test, eq)
    local Motion = require("../src/shared/CloudMotionRules")
    test("elemental patrols have different chase radii", function()
        local air = Motion.parameters("Air")
        local storm = Motion.parameters("Storm")
        local earth = Motion.parameters("Earth")
        eq(air > earth, true, "air moves farther")
        eq(storm > earth, true, "storm moves farther")
    end)
    test("cloud patrol stays bounded and deterministic", function()
        for _, element in ipairs({"Air", "Storm", "Cosmic", "Water", "Fire", "Earth"}) do
            local radius = Motion.parameters(element)
            for _, t in ipairs({0, 1, 100, 100000}) do
                local x, y, z = Motion.offset(element, t, 1.5)
                eq(math.abs(x) <= radius + 0.00001, true, "bounded x")
                eq(math.abs(z) <= radius + 0.00001, true, "bounded z")
                eq(math.abs(y) <= 0.65001, true, "bounded y")
                local again = Motion.offset(element, t, 1.5)
                eq(x, again, "deterministic")
            end
        end
    end)
    test("invalid patrol inputs never produce invalid positions", function()
        for _, value in ipairs({math.huge, -math.huge, 0/0}) do
            local x, y, z = Motion.offset("Air", value, 0)
            eq(x, 0, "invalid time x")
            eq(y, 0, "invalid time y")
            eq(z, 0, "invalid time z")
            eq(select(1, Motion.offset("Air", 1, value)), 0, "invalid phase")
        end
    end)
end

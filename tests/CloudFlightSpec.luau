return function(test, eq)
    local Flight = require("../src/shared/CloudFlightRules")
    test("elemental flight patterns are deterministic and distinct", function()
        local ax, az = Flight.offset("Air", 1, 7)
        local bx, bz = Flight.offset("Air", 1, 7)
        eq(ax, bx, "x deterministic")
        eq(az, bz, "z deterministic")
        local wx, wz = Flight.offset("Water", 1, 7)
        eq(ax == wx and az == wz, false, "element-specific path")
    end)
    test("flight never leaves bounded horizontal spawn envelope", function()
        for _, element in ipairs({"Air","Water","Storm","Nature","Cosmic","Ice"}) do
            for tick = 0, 100 do
                local x, z = Flight.offset(element, tick * 0.3, 4)
                eq(math.abs(x) <= 4.01 and math.abs(z) <= 4.01, true, "safe flight bounds")
            end
        end
    end)
    test("malformed flight inputs return stationary offsets", function()
        local x,z = Flight.offset("Storm", math.huge, 1)
        eq(x, 0, "infinite elapsed x")
        eq(z, 0, "infinite elapsed z")
        x,z = Flight.offset("Air", 2, 0/0)
        eq(x, 0, "nan seed x")
        eq(z, 0, "nan seed z")
    end)
end

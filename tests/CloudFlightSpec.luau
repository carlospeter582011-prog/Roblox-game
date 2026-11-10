local Flight = require("../src/shared/CloudFlight")
return function(test, eq)
    test("cloud flight stays within walkable spawn regions", function()
        local region = { minX = -55, maxX = 55, minZ = -55, maxZ = 55 }
        for seed = 1, 12 do
            for t = 0, 120, 3 do
                local x, z = Flight.position(53, -53, region, t, seed)
                eq(x <= 53 and x >= -53, true, "x bounded")
                eq(z <= 53 and z >= -53, true, "z bounded")
            end
        end
    end)
    test("cloud flight is deterministic and reacts to elapsed time", function()
        local region = { minX = 0, maxX = 100, minZ = 0, maxZ = 100 }
        local x, z = Flight.position(50, 50, region, 1, 3)
        local xx, zz = Flight.position(50, 50, region, 1, 3)
        eq(x, xx, "same x")
        eq(z, zz, "same z")
        local nextX = Flight.position(50, 50, region, 10, 3)
        eq(x ~= nextX, true, "moves horizontally")
        local badX, badZ = Flight.offset(math.huge, 3, 3)
        eq(badX, 0, "invalid time")
        eq(badZ, 0, "invalid time z")
    end)
end

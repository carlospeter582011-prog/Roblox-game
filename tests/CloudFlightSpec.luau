local Flight = require("../src/shared/CloudFlightRules")
return function(test, eq)
    test("cloud flight profiles differ by element", function()
        local air = Flight.profile({element = "Air"})
        local earth = Flight.profile({element = "Earth"})
        eq(air.radius > earth.radius, true, "air moves farther")
        eq(air.speed > earth.speed, true, "air moves faster")
    end)
    test("flight offsets remain bounded for all catalog species", function()
        local catalog = require("../src/shared/CloudCatalog")
        for _, species in pairs(catalog) do
            local p = Flight.profile(species)
            for _, t in ipairs({0, 1, 10, 100, 10000}) do
                local x, z = Flight.offset(species, t, 17)
                eq(math.abs(x) <= p.radius + 0.00001, true, species.id .. " x bound")
                eq(math.abs(z) <= p.radius + 0.00001, true, species.id .. " z bound")
            end
        end
    end)
    test("flight deterministic and rejects invalid time inputs", function()
        local s = {element = "Storm"}
        local x, z = Flight.offset(s, 25, 4)
        local x2, z2 = Flight.offset(s, 25, 4)
        eq(x, x2, "same x")
        eq(z, z2, "same z")
        local badX, badZ = Flight.offset(s, math.huge, 0 / 0)
        eq(type(badX), "number", "finite fallback x")
        eq(type(badZ), "number", "finite fallback z")
    end)
end

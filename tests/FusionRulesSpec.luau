local Fusion = require("../src/shared/FusionRules")
local catalog = { breeze = { id = "breeze" }, frost = { id = "frost" } }
return function(test, eq)
    test("fusion preserves last owned cloud and spends exactly two", function()
        local owned, bonds = { breeze = 3 }, {}
        local ok, points = Fusion.apply("breeze", owned, bonds, catalog)
        eq(ok, true, "fusion accepted")
        eq(points, 20, "bond mastery")
        eq(owned.breeze, 1, "one original remains")
        eq(Fusion.canFuse("breeze", owned, catalog), false, "cannot spend last copy")
    end)
    test("fusion rejects unknown species and malformed counts", function()
        for _, n in ipairs({ 0, 1, 2, 2.5, -1, math.huge }) do
            eq(Fusion.canFuse("breeze", { breeze = n }, catalog), false, "invalid count")
        end
        eq(Fusion.canFuse("unknown", { unknown = 99 }, catalog), false, "catalog check")
    end)
    test("fusion stacks mastery but caps it safely", function()
        local owned, bonds = { frost = 5 }, { frost = 999999 }
        local ok, points = Fusion.apply("frost", owned, bonds, catalog)
        eq(ok, true, "fuse")
        eq(points, 1000000, "cap")
        eq(owned.frost, 3, "consumption")
    end)
end

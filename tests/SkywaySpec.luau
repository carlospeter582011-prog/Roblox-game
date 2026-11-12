local Rules = require("../src/shared/SkywayRules")
assert(Rules.canLaunch("meadow_to_outlook", 8, 100, 0, true))
assert(not Rules.canLaunch("unknown", 8, 100, 0, true))
assert(not Rules.canLaunch("meadow_to_outlook", 16, 100, 0, true))
assert(not Rules.canLaunch("meadow_to_outlook", 8, 100, 96, true))
assert(not Rules.canLaunch("meadow_to_outlook", 8, 100, 0, false))
assert(not Rules.canLaunch("meadow_to_outlook", 0/0, 100, 0, true))
assert(not Rules.canLaunch("meadow_to_outlook", 8, math.huge, 0, true))
for id, route in pairs(Rules.routes) do
    assert(type(id) == "string")
    assert(#route.from == 3 and #route.to == 3)
    for _, position in ipairs({ route.from, route.to }) do
        for _, coordinate in ipairs(position) do
            assert(type(coordinate) == "number" and coordinate == coordinate and math.abs(coordinate) < 1000)
        end
    end
end
print("SkywaySpec passed")

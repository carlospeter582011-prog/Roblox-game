-- Regression tests for Frost Spires attunement rules.
local Rules = require("../src/shared/FrostRules")

return function(test, eq)
    test("frost attune rejects out of range and not ready", function()
        eq(Rules.canAttune(20, true, nil, 1000), false, "too far")
        eq(Rules.canAttune(10, false, nil, 1000), false, "not ready")
        eq(Rules.canAttune(-1, true, nil, 1000), false, "negative distance")
        eq(Rules.canAttune(math.huge, true, nil, 1000), false, "inf")
        eq(Rules.canAttune(10, true, nil, 1000), true, "valid")
    end)

    test("frost attune enforces cooldown and accepts after window", function()
        eq(Rules.canAttune(8, true, 1000, 1030), false, "inside cooldown")
        eq(Rules.canAttune(8, true, 1000, 1041), true, "after cooldown")
        eq(Rules.canAttune(8, true, nil, 1000), true, "first time")
    end)
end

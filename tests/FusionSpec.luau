-- Regression tests for CloudFusionRules
local Rules = require("../src/shared/CloudFusionRules")

return function(test, eq)
    test("fusion requires at least two of a valid species", function()
        eq(Rules.canFuse("breeze", { breeze = 2 }), true, "exactly two")
        eq(Rules.canFuse("breeze", { breeze = 1 }), false, "one left")
        eq(Rules.canFuse("breeze", { breeze = 0 }), false, "zero")
        eq(Rules.canFuse("breeze", {}), false, "missing")
        eq(Rules.canFuse("", { breeze = 5 }), false, "empty id")
        eq(Rules.canFuse("breeze", { breeze = 2.5 }), false, "non-integer")
        eq(Rules.canFuse("breeze", { breeze = math.huge }), false, "infinite")
    end)

    test("successful fusion consumes two and awards bonus", function()
        local result = Rules.fuse("breeze", { breeze = 5 }, 100)
        eq(result.ok, true, "ok")
        eq(result.newCount, 3, "consumed")
        eq(result.xpBonus, 50, "half xp")
        eq(result.coinRefund, 5, "refund")
    end)

    test("insufficient fusion returns reason without side effects", function()
        local result = Rules.fuse("breeze", { breeze = 1 }, 100)
        eq(result.ok, false, "not ok")
        eq(result.reason, "insufficient", "reason")
        eq(result.newCount, nil, "no count")
    end)
end

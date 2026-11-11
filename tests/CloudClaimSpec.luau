local Claims = require("../src/shared/CloudClaimRules")
return function(test, eq)
    test("a cloud can be claimed only once while its reward is pending", function()
        local instance, active, claims = {}, {}, {}
        active["1"] = instance
        eq(Claims.begin(claims, "1", active, instance), true, "first claim")
        eq(Claims.begin(claims, "1", active, instance), false, "concurrent duplicate rejected")
        Claims.finish(claims, "1")
        eq(Claims.begin(claims, "1", active, instance), true, "failed reward may retry")
    end)
    test("stale and invalid cloud claims cannot award rewards", function()
        local current, old, claims = {}, {}, {}
        local active = { ["1"] = current }
        eq(Claims.begin(claims, "1", active, old), false, "stale instance")
        eq(Claims.begin(claims, "2", active, current), false, "removed cloud")
        eq(Claims.begin(claims, nil, active, current), false, "bad id")
        eq(Claims.begin(claims, "1", active, current), true, "valid instance")
        active["1"] = nil
        Claims.finish(claims, "1")
        eq(Claims.begin(claims, "1", active, current), false, "removed cannot retry")
    end)
end

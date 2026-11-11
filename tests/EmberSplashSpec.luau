local Rules = require("../src/shared/CatchRules")
return function(test, eq)
    test("ember splash selects nearest server-validated clouds with deterministic ties", function()
        local result = Rules.selectEmberSplashTargets("primary", {
            { id = "z", splashDistance = 3, inPlayerRange = true },
            { id = "b", splashDistance = 2, inPlayerRange = true },
            { id = "a", splashDistance = 2, inPlayerRange = true },
            { id = "far", splashDistance = 10, inPlayerRange = true },
        }, 9, 3)
        eq(#result, 3, "capped at three total")
        eq(result[1], "primary", "primary always first")
        eq(result[2], "a", "tie by stable id")
        eq(result[3], "b", "next nearest")
    end)
    test("ember splash excludes out-of-range, duplicate, malformed and unapproved clouds", function()
        local result = Rules.selectEmberSplashTargets("p", {
            { id = "p", splashDistance = 0, inPlayerRange = true },
            { id = "behind", splashDistance = 1, inPlayerRange = false },
            { id = "edge", splashDistance = 9, inPlayerRange = true },
            { id = "edge", splashDistance = 9, inPlayerRange = true },
            { id = "outside", splashDistance = 9.01, inPlayerRange = true },
            { id = "nan", splashDistance = 0/0, inPlayerRange = true },
            { id = 4, splashDistance = 0, inPlayerRange = true },
        }, 9, 3)
        eq(#result, 2, "only one valid secondary")
        eq(result[2], "edge", "boundary included")
    end)
    test("ember splash invalid parameters fail closed to primary target", function()
        eq(#Rules.selectEmberSplashTargets("p", {}, math.huge, 3), 1, "infinite radius")
        eq(#Rules.selectEmberSplashTargets("p", {}, 9, 0/0), 1, "NaN limit")
        eq(#Rules.selectEmberSplashTargets("p", {}, -1, 3), 1, "negative radius")
        eq(#Rules.selectEmberSplashTargets("p", {}, 9, 0), 1, "zero limit")
        eq(#Rules.selectEmberSplashTargets("p", {}, 21, 3), 1, "oversized radius")
    end)
end

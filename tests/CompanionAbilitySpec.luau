-- Air companion reach: pure tests, no Roblox runtime required.
local Rules = require("../src/shared/CompanionRules")
return function(test, eq)
    local catalog = {
        breeze = { element = "Air" },
        drizzle = { element = "Water" },
    }
    local owned = { breeze = 1, drizzle = 2 }
    test("Air companion reach increases with earned Bond", function()
        eq(Rules.airReachBonus("breeze", owned, catalog, { breeze = 0 }), 0, "new")
        eq(Rules.airReachBonus("breeze", owned, catalog, { breeze = 10 }), 1, "level one")
        eq(Rules.airReachBonus("breeze", owned, catalog, { breeze = 40 }), 2, "level two")
        eq(Rules.airReachBonus("breeze", owned, catalog, { breeze = 100 }), 3, "level three")
        eq(Rules.airReachBonus("breeze", owned, catalog, { breeze = 999999 }), 3, "capped")
    end)
    test("Air reach rejects unowned, unknown, and other elements", function()
        eq(Rules.airReachBonus("breeze", {}, catalog, { breeze = 100 }), 0, "not owned")
        eq(Rules.airReachBonus("missing", owned, catalog, { missing = 100 }), 0, "not catalogued")
        eq(Rules.airReachBonus("drizzle", owned, catalog, { drizzle = 100 }), 0, "water not air")
        eq(Rules.airReachBonus("breeze", owned, catalog, { breeze = 0/0 }), 0, "invalid points")
        eq(Rules.airReachBonus(nil, owned, catalog, { breeze = 100 }), 0, "no selection")
    end)
    test("Water companion grants capped cross-element catch XP", function()
        eq(Rules.waterLearningXp(100, "drizzle", owned, catalog, { drizzle = 0 }), 0, "unbonded")
        eq(Rules.waterLearningXp(100, "drizzle", owned, catalog, { drizzle = 10 }), 3, "bond 1")
        eq(Rules.waterLearningXp(100, "drizzle", owned, catalog, { drizzle = 40 }), 6, "bond 2")
        eq(Rules.waterLearningXp(100, "drizzle", owned, catalog, { drizzle = 100 }), 9, "bond 3")
        eq(Rules.waterLearningXp(100, "drizzle", owned, catalog, { drizzle = 100000 }), 9, "cap")
    end)
    test("Water learning rejects unowned companions and invalid reward inputs", function()
        eq(Rules.waterLearningXp(100, "drizzle", {}, catalog, { drizzle = 100 }), 0, "unowned")
        eq(Rules.waterLearningXp(100, "breeze", owned, catalog, { breeze = 100 }), 0, "air")
        eq(Rules.waterLearningXp(100, "missing", owned, catalog, { missing = 100 }), 0, "unknown")
        eq(Rules.waterLearningXp(0/0, "drizzle", owned, catalog, { drizzle = 100 }), 0, "nan")
        eq(Rules.waterLearningXp(math.huge, "drizzle", owned, catalog, { drizzle = 100 }), 0, "infinite")
        eq(Rules.waterLearningXp(-1, "drizzle", owned, catalog, { drizzle = 100 }), 0, "negative")
    end)

end

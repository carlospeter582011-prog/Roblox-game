-- Pure tests for NurseryRules. No Roblox globals.
local Rules = require("../src/shared/NurseryRules")

return function(test, eq)
    local catalog = {
        breeze = { id = "breeze", name = "Breeze", element = "Air" },
        drizzle = { id = "drizzle", name = "Drizzle", element = "Water" },
    }

    test("raise cost scales with bond level", function()
        eq(Rules.raiseCost(0), 25, "level 0")
        eq(Rules.raiseCost(10), 40, "level 1")
        eq(Rules.raiseCost(40), 55, "level 2")
        eq(Rules.raiseCost(100), 70, "level 3")
        eq(Rules.raiseCost(-1), 50, "invalid defaults")
        eq(Rules.raiseCost(0 / 0), 50, "nan defaults")
    end)

    test("canRaise requires owned companion, enough coins and valid numbers", function()
        local species = { breeze = 2 }
        local bond = { breeze = 5 }
        eq(Rules.canRaise("breeze", 30, bond, species, catalog), true, "affordable")
        eq(Rules.canRaise("breeze", 20, bond, species, catalog), false, "too few coins")
        eq(Rules.canRaise("drizzle", 100, bond, species, catalog), false, "not owned")
        eq(Rules.canRaise("breeze", 100, bond, { breeze = 0 }, catalog), false, "zero count")
        eq(Rules.canRaise("breeze", math.huge, bond, species, catalog), false, "infinite coins")
        eq(Rules.canRaise("breeze", 100, { breeze = 0 / 0 }, species, catalog), false, "nan bond")
        eq(Rules.canRaise("missing", 100, {}, {}, catalog), false, "unknown species")
    end)

    test("applyRaise deducts cost and advances bond or returns nil", function()
        local species = { breeze = 1 }
        local bond = { breeze = 9 }
        local newCoins, newPoints = Rules.applyRaise("breeze", 50, bond, species, catalog)
        eq(newCoins, 10, "cost 40 at level 1")
        eq(newPoints, 10, "advanced one")
        eq(Rules.applyRaise("breeze", 10, bond, species, catalog), nil, "cannot afford")
        eq(Rules.applyRaise("drizzle", 100, bond, species, catalog), nil, "not owned")
    end)
end

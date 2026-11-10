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
    test("Earth companions earn a bounded first-crystal Coin bonus", function()
        local earthCatalog = { pebble = { element = "Earth" }, breeze = { element = "Air" } }
        local earthOwned = { pebble = 1, breeze = 1 }
        eq(Rules.earthCrystalBonus(100, "pebble", earthOwned, earthCatalog, { pebble = 0 }), 0, "unbonded")
        eq(Rules.earthCrystalBonus(100, "pebble", earthOwned, earthCatalog, { pebble = 10 }), 4, "level 1")
        eq(Rules.earthCrystalBonus(100, "pebble", earthOwned, earthCatalog, { pebble = 40 }), 8, "level 2")
        eq(Rules.earthCrystalBonus(100, "pebble", earthOwned, earthCatalog, { pebble = 100 }), 12, "level 3")
        eq(Rules.earthCrystalBonus(11, "pebble", earthOwned, earthCatalog, { pebble = 100 }), 1, "integer floor")
        eq(Rules.earthCrystalBonus(100, "breeze", earthOwned, earthCatalog, { breeze = 100 }), 0, "wrong element")
        eq(Rules.earthCrystalBonus(100, "pebble", {}, earthCatalog, { pebble = 100 }), 0, "unowned")
        eq(Rules.earthCrystalBonus(math.huge, "pebble", earthOwned, earthCatalog, { pebble = 100 }), 0, "invalid reward")
        eq(Rules.earthCrystalBonus(100, "pebble", earthOwned, earthCatalog, { pebble = 0/0 }), 0, "invalid bond")
    end)
end

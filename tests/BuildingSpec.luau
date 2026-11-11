-- Unit tests for building placement rules.
local Rules = require("../src/shared/BuildingRules")
local Catalog = {
    lantern = { id = "lantern", costCoins = 100 },
    flower = { id = "flower", costCoins = 50 },
}

return function(test, eq)
    test("can place valid building within bounds with enough coins", function()
        local data = { coins = 200, buildings = {} }
        local ok, item = Rules.canPlace(Catalog, data, "lantern", { x = 0, y = 15, z = 0 })
        eq(ok, true, "allowed")
        eq(item.costCoins, 100, "item")
    end)

    test("rejects insufficient coins", function()
        local data = { coins = 40, buildings = {} }
        local ok, err = Rules.canPlace(Catalog, data, "lantern", { x = 0, y = 15, z = 0 })
        eq(ok, false, "rejected")
        eq(err, "Not enough coins", "reason")
    end)

    test("rejects outside bounds", function()
        local data = { coins = 200, buildings = {} }
        local ok, err = Rules.canPlace(Catalog, data, "lantern", { x = 100, y = 15, z = 0 })
        eq(ok, false, "rejected")
        eq(err, "Outside island bounds", "reason")
    end)

    test("place deducts coins and adds building", function()
        local data = { coins = 200, buildings = {} }
        local ok = Rules.place(Catalog, data, "flower", { x = 5, y = 12, z = -10 })
        eq(ok, true, "placed")
        eq(data.coins, 150, "coins deducted")
        eq(#data.buildings, 1, "count")
        eq(data.buildings[1].id, "flower", "id")
    end)

    test("rejects when full", function()
        local data = { coins = 10000, buildings = {} }
        for i = 1, 50 do table.insert(data.buildings, { id = "flower" }) end
        local ok, err = Rules.canPlace(Catalog, data, "lantern", { x = 0, y = 15, z = 0 })
        eq(ok, false, "full")
        eq(err, "Island is full", "reason")
    end)
end

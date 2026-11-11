return function(test, eq)
    local Craft = require("../src/shared/CloudCraftRules")
    local function player()
        return { coins = 1000, species = { breeze = 4, drizzle = 3, mist = 3 }, craftedItems = {} }
    end
    test("crafting consumes duplicates and coins without changing input", function()
        local p = player()
        local result = Craft.preview(p, "breeze_charm")
        eq(result.coins, 920, "coins spent")
        eq(result.species.breeze, 1, "last specimen retained")
        eq(result.craftedItems.breeze_charm, 1, "crafted item")
        eq(p.coins, 1000, "input coins unchanged")
        eq(p.species.breeze, 4, "input species unchanged")
        eq(p.craftedItems.breeze_charm, nil, "input items unchanged")
    end)
    test("crafting rejects missing ingredients, unknown recipes and bad profiles", function()
        local p = player()
        p.species.breeze = 3
        local r, reason = Craft.preview(p, "breeze_charm")
        eq(r, nil, "not crafted")
        eq(reason, "insufficient_duplicates", "preserve last")
        eq(select(2, Craft.preview(p, "bogus")), "unknown_recipe", "unknown")
        p.coins = math.huge
        eq(select(2, Craft.preview(p, "breeze_charm")), "invalid_profile", "infinite coins")
    end)
    test("crafting enforces currency and inventory limits", function()
        local p = player()
        p.coins = 79
        eq(select(2, Craft.preview(p, "breeze_charm")), "insufficient_coins", "coin gate")
        p.coins = 1000
        p.craftedItems.breeze_charm = 1000000
        eq(select(2, Craft.preview(p, "breeze_charm")), "inventory_full", "cap")
    end)
end

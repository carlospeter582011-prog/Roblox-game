local Crafting = require("../src/shared/CraftingRules")
return function(test, eq)
    test("crafting preview charges exact coins and ingredients", function()
        local input = { air_essence = 5, nature_essence = 2 }
        local result = Crafting.preview("breeze_lure", 100, input)
        eq(result.coins, 20, "coins")
        eq(result.materials.air_essence, 2, "remaining air")
        eq(result.output, "breeze_lure", "output")
        eq(input.air_essence, 5, "input unchanged")
    end)
    test("crafting rejects missing ingredients and forged recipes", function()
        local result, reason = Crafting.preview("not_a_recipe", 999, { air_essence = 100 })
        eq(result, nil, "unknown rejected")
        eq(reason, "unknown_recipe", "reason")
        eq(Crafting.canCraft("storm_lure", 999, { air_essence = 2, storm_essence = 1 }), false, "missing storm")
    end)
    test("crafting rejects malformed balances and prevents negative results", function()
        for _, coins in ipairs({ -1, math.huge, 0/0, 1.5 }) do
            eq(Crafting.canCraft("breeze_lure", coins, { air_essence = 3 }), false, "bad coins")
        end
        eq(Crafting.canCraft("breeze_lure", 80, { air_essence = math.huge }), false, "bad inventory")
        eq(Crafting.canCraft("breeze_lure", 79, { air_essence = 3 }), false, "not enough coins")
    end)
    test("batch crafting aggregates costs and preserves all source tables", function()
        local materials = { air_essence = 12, storm_essence = 4 }
        local owned = { breeze_lure = 2 }
        local result, reason = Crafting.previewBatch({
            { recipeId = "breeze_lure", quantity = 2 },
            { recipeId = "storm_lure", quantity = 1 },
        }, 400, materials, owned)
        eq(reason, "ok", "valid batch")
        eq(result.coins, 60, "remaining coins")
        eq(result.materials.air_essence, 4, "air remaining")
        eq(result.materials.storm_essence, 0, "storm remaining")
        eq(result.items.breeze_lure, 4, "lures added")
        eq(result.items.storm_lure, 1, "storm added")
        eq(materials.air_essence, 12, "materials unchanged")
        eq(owned.breeze_lure, 2, "items unchanged")
    end)
    test("batch crafting rejects invalid later step without partial mutation", function()
        local materials = { air_essence = 9, storm_essence = 0 }
        local result, reason = Crafting.previewBatch({
            { recipeId = "breeze_lure", quantity = 1 },
            { recipeId = "storm_lure", quantity = 1 },
        }, 400, materials, {})
        eq(result, nil, "entire queue rejected")
        eq(reason, "insufficient_materials", "later step fails")
        eq(materials.air_essence, 9, "original materials preserved")
    end)
    test("batch crafting bounds quantities and output overflow", function()
        local inv = { air_essence = 300 }
        eq(Crafting.previewBatch({{recipeId = "breeze_lure", quantity = 0}}, 1000, inv, {}), nil, "zero")
        eq(Crafting.previewBatch({{recipeId = "breeze_lure", quantity = math.huge}}, 1000, inv, {}), nil, "infinity")
        eq(Crafting.previewBatch({{recipeId = "breeze_lure", quantity = 101}}, 1000, inv, {}), nil, "batch cap")
        local result, reason = Crafting.previewBatch({{recipeId = "breeze_lure", quantity = 1}}, 100, inv, {breeze_lure = 1000000000})
        eq(result, nil, "overflow rejected")
        eq(reason, "output_overflow", "overflow reason")
    end)
end

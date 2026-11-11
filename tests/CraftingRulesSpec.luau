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
end

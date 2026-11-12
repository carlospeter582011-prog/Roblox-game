-- Regression tests for CraftRules. Pure Luau, no Roblox.
return function(test, eq)
    local Craft = require("../src/shared/CraftRules")

    test("totalSurplus counts only extras above one", function()
        eq(Craft.totalSurplus({ breeze = 3, drizzle = 1, thunder = 5 }), 6, "3-1 + 5-1")
        eq(Craft.totalSurplus({ breeze = 1, drizzle = 0 }), 0, "no extras")
        eq(Craft.totalSurplus({}), 0, "empty")
        eq(Craft.totalSurplus(nil), 0, "nil")
    end)

    test("canCraft rejects insufficient surplus or coins", function()
        local data = { coins = 30, species = { breeze = 3 } }
        local ok, msg = Craft.canCraft("speed_essence", data)
        eq(ok, false, "not enough")
        eq(type(msg), "string", "message")

        data.coins = 100
        data.species.breeze = 10
        ok = Craft.canCraft("speed_essence", data)
        eq(ok, true, "enough")
    end)

    test("applyCraft deducts surplus and coins and records crafted", function()
        local data = { coins = 200, species = { breeze = 8, drizzle = 4 }, crafted = {} }
        local ok, recipe = Craft.applyCraft("speed_essence", data)
        eq(ok, true, "crafted")
        eq(recipe.id, "speed_essence", "recipe")
        eq(data.coins, 150, "coins deducted")
        eq(Craft.totalSurplus(data.species), 5, "surplus reduced by 5")
        eq(data.crafted.speed_essence, 1, "recorded")
    end)

    test("applyCraft fails when cannot afford and does not mutate", function()
        local data = { coins = 10, species = { breeze = 10 } }
        local beforeCoins = data.coins
        local beforeSurplus = Craft.totalSurplus(data.species)
        local ok = Craft.applyCraft("speed_essence", data)
        eq(ok, false, "failed")
        eq(data.coins, beforeCoins, "coins unchanged")
        eq(Craft.totalSurplus(data.species), beforeSurplus, "surplus unchanged")
    end)
end

-- CraftingRules regression tests. Pure logic only.
return function(test, eq)
    local Rules = require("../src/shared/CraftingRules")
    local Materials = require("../src/shared/MaterialCatalog")

    test("crafting awards correct materials by element and rarity", function()
        local awards = Rules.awardMaterials("Air", "Common", function() return 0.5 end)
        eq(awards.air_essence, 1, "common air")
        awards = Rules.awardMaterials("Fire", "Legendary", function() return 0.1 end)
        eq(awards.fire_spark >= 3, true, "legendary bonus chance")
        awards = Rules.awardMaterials("Unknown", "Common", function() return 0 end)
        eq(next(awards), nil, "unknown element no award")
    end)

    test("canCraft rejects insufficient resources and already owned", function()
        local profile = { coins = 30, materials = { air_essence = 3 }, ownedTools = {} }
        local ok, reason = Rules.canCraft("wind_lasso_craft", profile, Materials)
        eq(ok, false, "insufficient coins")
        eq(reason, "insufficient_coins", "reason")
        profile.coins = 100
        profile.materials.air_essence = 2
        ok, reason = Rules.canCraft("wind_lasso_craft", profile, Materials)
        eq(ok, false, "insufficient materials")
        profile.materials.air_essence = 10
        profile.ownedTools.wind_lasso = true
        ok, reason = Rules.canCraft("wind_lasso_craft", profile, Materials)
        eq(ok, false, "already owned")
    end)

    test("applyCraft consumes resources and unlocks tool atomically", function()
        local profile = {
            coins = 200,
            materials = { air_essence = 10, water_droplet = 10 },
            ownedTools = { starter_net = true },
        }
        local ok, tool = Rules.applyCraft("wind_lasso_craft", profile, Materials)
        eq(ok, true, "craft succeeded")
        eq(tool, "wind_lasso", "result tool")
        eq(profile.coins, 160, "coins deducted")
        eq(profile.materials.air_essence, 5, "materials consumed")
        eq(profile.ownedTools.wind_lasso, true, "tool unlocked")
        -- Second attempt fails
        ok = Rules.applyCraft("wind_lasso_craft", profile, Materials)
        eq(ok, false, "cannot recraft")
    end)

    test("invalid recipe and missing catalog are rejected", function()
        local profile = { coins = 999, materials = { air_essence = 99 }, ownedTools = {} }
        local ok, reason = Rules.canCraft("nonexistent", profile, Materials)
        eq(ok, false, "unknown recipe")
        eq(reason, "unknown_recipe", "reason")
        ok = Rules.canCraft("wind_lasso_craft", profile, nil)
        eq(ok, false, "no catalog")
    end)
end

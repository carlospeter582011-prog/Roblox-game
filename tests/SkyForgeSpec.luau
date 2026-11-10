local Forge = require("../src/shared/SkyForgeRules")
return function(test, eq)
    test("forge requires valid server-owned balances and unlocks", function()
        eq(Forge.validate("spark", 60, 5), true, "valid spark")
        eq(Forge.validate("gale", 180, 24), false, "locked gale")
        eq(Forge.validate("tempest", 449, 75), false, "insufficient coins")
        eq(Forge.validate("spark", math.huge, 5), false, "infinite coins")
        eq(Forge.validate("spark", 60, 0/0), false, "nan catches")
        eq(Forge.validate({}, 60, 5), false, "bad id")
        eq(Forge.validate("unknown", 1000, 1000), false, "unknown recipe")
    end)
    test("forge recipes are affordable bounded Coin sinks", function()
        for id, recipe in pairs(Forge.Recipes) do
            eq(Forge.validate(id, recipe.cost, recipe.catches), true, "unlocked " .. id)
            eq(recipe.xp > 0 and recipe.xp < recipe.cost, true, "no free currency loop " .. id)
        end
    end)
end

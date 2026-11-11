-- Unit tests for FusionRules. Registered from tests/run.luau.
return function(test, eq)
    local Rules = require("../src/shared/FusionRules")

    test("fusion recipes exist and are well-formed", function()
        eq(#Rules.RECIPES >= 3, true, "at least three recipes")
        local breeze = Rules.findRecipe("breeze_pair")
        eq(breeze ~= nil, true, "breeze recipe found")
        eq(breeze.output.speciesId, "gale", "output gale")
    end)

    test("canFuse rejects insufficient species or captures", function()
        local recipe = Rules.findRecipe("breeze_pair")
        local data = { captures = 5, species = { breeze = 2 } }
        eq(Rules.canFuse(data, recipe), false, "too few captures")
        data.captures = 15
        data.species.breeze = 1
        eq(Rules.canFuse(data, recipe), false, "not enough breeze")
        data.species.breeze = 2
        eq(Rules.canFuse(data, recipe), true, "eligible")
        eq(Rules.canFuse(nil, recipe), false, "nil data")
        eq(Rules.canFuse(data, nil), false, "nil recipe")
    end)

    test("applyFusion consumes inputs and awards output", function()
        local recipe = Rules.findRecipe("breeze_pair")
        local data = { captures = 20, species = { breeze = 3, other = 1 } }
        eq(Rules.applyFusion(data, recipe), true, "applied")
        eq(data.species.breeze, 1, "breeze reduced")
        eq(data.species.gale, 1, "gale awarded")
        eq(data.species.other, 1, "unrelated preserved")
        -- second fuse fails
        eq(Rules.applyFusion(data, recipe), false, "not enough for second")
    end)

    test("applyFusion does not mutate on failure", function()
        local recipe = Rules.findRecipe("drizzle_pair")
        local data = { captures = 10, species = { drizzle = 1 } }
        local before = { drizzle = 1 }
        eq(Rules.applyFusion(data, recipe), false, "failed")
        eq(data.species.drizzle, 1, "unchanged")
    end)
end

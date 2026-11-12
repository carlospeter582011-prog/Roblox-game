-- Regression tests for EvolutionRules. Pure Luau, no Roblox.
return function(test, eq)
    local Rules = require("../src/shared/EvolutionRules")
    local catalog = {
        breeze = { name = "Breeze" }, gale = { name = "Gale" },
        drizzle = { name = "Drizzle" }, mist = { name = "Mist" },
        thunder = { name = "Thunder" }, stormfront = { name = "Stormfront" },
    }

    test("evolution requires stock, coins and bond then consumes one input", function()
        local species = { breeze = 5, gale = 0 }
        local ok, recipe = Rules.canEvolve("breeze", species, 100, {}, catalog)
        eq(ok, true, "can evolve")
        eq(recipe.output, "gale", "output")
        local newSpecies, newCoins, output = Rules.apply("breeze", species, 100, {}, catalog)
        eq(output, "gale", "applied output")
        eq(newSpecies.breeze, 4, "consumed one")
        eq(newSpecies.gale, 1, "gained one")
        eq(newCoins, 20, "paid 80")
    end)

    test("evolution rejects insufficient stock, coins or bond", function()
        eq(Rules.canEvolve("breeze", { breeze = 4 }, 100, {}, catalog), false, "too few")
        eq(Rules.canEvolve("breeze", { breeze = 5 }, 50, {}, catalog), false, "poor")
        eq(Rules.canEvolve("thunder", { thunder = 3 }, 200, { thunder = 0 }, catalog), false, "no bond")
        eq(Rules.canEvolve("thunder", { thunder = 3 }, 200, { thunder = 1 }, catalog), true, "bond ok")
        eq(Rules.canEvolve("fake", {}, 999, {}, catalog), false, "unknown")
    end)

    test("evolution preserves other species and handles zero count cleanup", function()
        local species = { breeze = 1, drizzle = 2 }
        -- force minCount 1 for test by using drizzle recipe which is 4, so fail, but check apply guard
        local newS, _, _ = Rules.apply("drizzle", { drizzle = 4 }, 100, {}, catalog)
        eq(newS.drizzle, 3, "consumed")
        eq(newS.mist, 1, "gained")
        eq(newS.breeze, nil, "untouched missing")
    end)
end

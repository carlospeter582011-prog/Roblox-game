-- Deterministic ecosystem selection regression tests (plain Luau).
return function(test, eq)
    local Spawn = require("../src/shared/SpawnRules")
    local pool = {
        air = {spawnWeight = 1, element = "Air"},
        storm = {spawnWeight = 1, element = "Storm"},
        invalid = {spawnWeight = math.huge, element = "Air"},
    }
    test("biome weighted selection favors native element without excluding others", function()
        eq(Spawn.rollSpecies(pool, function() return 0.1 end, "Storm"), "air", "non-native still possible")
        eq(Spawn.rollSpecies(pool, function() return 0.3 end, "Storm"), "storm", "native favored")
        eq(Spawn.rollSpecies(pool, function() return 0.6 end, "Air"), "air", "air favored")
        eq(Spawn.rollSpecies(pool, function() return 0.99 end, nil), "storm", "unbiased fallback")
    end)
    test("spawn regions have stable native elements", function()
        eq(Spawn.regionBounds(1).element, "Nature", "meadow")
        eq(Spawn.regionBounds(2).element, "Air", "outlook")
        eq(Spawn.regionBounds(5).element, "Storm", "ridge")
        eq(Spawn.regionBounds(0), nil, "invalid sequence")
    end)
end

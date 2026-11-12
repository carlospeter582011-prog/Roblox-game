local Spawn = require("../src/shared/SpawnRules")
return function(test, eq)
    local catalog = {
        air = { element = "Air", spawnWeight = 1 },
        storm = { element = "Storm", spawnWeight = 1 },
    }
    test("regional affinity changes deterministic spawn outcome", function()
        eq(Spawn.rollForRegion(catalog, "StarterMeadow", function() return 0.6 end), "air", "meadow favors air")
        eq(Spawn.rollForRegion(catalog, "ThunderheadRidge", function() return 0.6 end), "storm", "ridge favors storm")
    end)
    test("unknown region falls back to standard weighting", function()
        eq(Spawn.rollForRegion(catalog, "Unknown", function() return 0.6 end), "storm", "fallback")
    end)
    test("region selection rejects invalid input and weights", function()
        eq(Spawn.rollForRegion({}, "StarterMeadow", function() return 0 end), nil, "empty")
        eq(Spawn.rollForRegion(nil, "StarterMeadow", function() return 0 end), nil, "nil catalog")
        eq(Spawn.rollForRegion(catalog, "StarterMeadow", nil), nil, "nil rng")
        eq(Spawn.rollForRegion({bad = {element = "Air", spawnWeight = math.huge}}, "StarterMeadow", function() return 0 end), nil, "invalid weight")
    end)
end

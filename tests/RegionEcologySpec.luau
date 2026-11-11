return function(test, eq)
    local Spawn = require("../src/shared/SpawnRules")
    local species = {
        air = { element = "Air", spawnWeight = 1 },
        storm = { element = "Storm", spawnWeight = 1 },
    }
    test("region ecology biases identical base weights", function()
        eq(Spawn.rollRegionSpecies(species, "StarterMeadow", function() return 0.6 end), "air", "meadow favors air")
        eq(Spawn.rollRegionSpecies(species, "ThunderheadRidge", function() return 0.6 end), "storm", "ridge favors storm")
    end)
    test("unknown region falls back to original deterministic roll", function()
        for _, roll in ipairs({ 0, 0.4, 0.9 }) do
            eq(Spawn.rollRegionSpecies(species, "Unknown", function() return roll end),
                Spawn.rollSpecies(species, function() return roll end), "fallback")
        end
    end)
    test("invalid and zero weights never spawn", function()
        local entries = { air = { element = "Air", spawnWeight = 0 }, storm = { element = "Storm", spawnWeight = math.huge } }
        eq(Spawn.rollRegionSpecies(entries, "ThunderheadRidge", function() return 0.5 end), nil, "invalid rejected")
    end)
end

-- Catalog expansion regression: catches, weighted spawns and saves depend on stable IDs.
return function(test, eq)
    local catalog = require("../src/shared/CloudCatalog")
    local spawn = require("../src/shared/SpawnRules")
    test("150 unique cloud species with valid spawn and catch economy metadata", function()
        local count = 0
        local names = {}
        for id, cloud in pairs(catalog) do
            count += 1
            eq(cloud.id, id, "stable catalog id")
            eq(type(cloud.name), "string", "name")
            eq(names[cloud.name], nil, "unique display name")
            names[cloud.name] = true
            eq(type(cloud.element), "string", "element")
            eq(type(cloud.spawnWeight), "number", "weight type")
            eq(cloud.spawnWeight > 0 and cloud.spawnWeight < math.huge, true, "finite positive weight")
            eq(cloud.baseCatchRadius >= 5 and cloud.baseCatchRadius <= 12, true, "bounded catch radius")
            eq(cloud.baseRewardCoins >= 0 and cloud.baseRewardCoins <= 500, true, "bounded coins")
            eq(#cloud.colorRGB, 3, "RGB channels")
            for _, channel in ipairs(cloud.colorRGB) do
                eq(channel >= 0 and channel <= 255, true, "valid RGB")
            end
        end
        eq(count, 150, "total species")
    end)
    test("new elemental cloud species participate in deterministic weighted spawns", function()
        local target = { aerocrown = catalog.aerocrown }
        eq(spawn.rollSpecies(target, function() return 0 end), "aerocrown", "new species is spawnable")
        eq(catalog.celestialhalo.element, "Cosmic", "cosmic species")
        eq(catalog.foresthalo.element, "Nature", "nature species")
    end)
end

-- Regression coverage for the expanded, save-stable cloud species catalog.
local Species = require("../src/shared/CloudCatalog")
local Spawn = require("../src/shared/SpawnRules")

return function(test, eq)
    test("species catalog contains 150 distinct persistent identifiers", function()
        local count = 0
        local names = {}
        for id, cloud in pairs(Species) do
            count += 1
            eq(cloud.id, id, "stable save key " .. id)
            eq(#id <= 40, true, "bounded save key " .. id)
            eq(names[cloud.name] == nil, true, "unique display name " .. cloud.name)
            names[cloud.name] = true
        end
        eq(count, 150, "catalog size")
    end)

    test("new elemental species span all eight intended families", function()
        local samples = {
            Air = "whistlewing", Water = "rainribbon", Storm = "stormcoil",
            Fire = "copperglow", Ice = "snowdrift", Nature = "seedwhirl",
            Earth = "sandripple", Cosmic = "stardustveil",
        }
        for element, id in pairs(samples) do
            eq(Species[id] ~= nil, true, "present " .. id)
            eq(Species[id].element, element, "element " .. id)
            eq(type(Species[id].spawnWeight) == "number" and Species[id].spawnWeight > 0, true, "spawnable " .. id)
        end
    end)

    test("new species can be selected by deterministic server spawn rules", function()
        local sample = { rainribbon = Species.rainribbon, stardustveil = Species.stardustveil }
        eq(Spawn.rollSpecies(sample, function() return 0 end), "rainribbon", "first species")
        eq(Spawn.rollSpecies(sample, function() return 0.999 end), "stardustveil", "last species")
    end)
end

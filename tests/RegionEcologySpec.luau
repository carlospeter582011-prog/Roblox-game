return function(test, eq)
    local Ecology = require("../src/shared/RegionEcology")
    local catalog = {
        breeze = { element = "Air", spawnWeight = 10 },
        thunder = { element = "Storm", spawnWeight = 10 },
        moss = { element = "Nature", spawnWeight = 10 },
    }
    test("habitats favor appropriate elements without removing species", function()
        eq(Ecology.weight(catalog.breeze, "EastwindOutlook"), 30, "air favored")
        eq(Ecology.weight(catalog.thunder, "ThunderheadRidge"), 32, "storm favored")
        eq(Ecology.weight(catalog.moss, "StarterMeadow"), 25, "nature favored")
        eq(Ecology.weight(catalog.moss, "ThunderheadRidge") > 0, true, "other species possible")
    end)
    test("habitat rolls are deterministic and input guarded", function()
        eq(Ecology.roll(catalog, "EastwindOutlook", function() return 0 end), "breeze", "first sorted")
        eq(Ecology.roll(catalog, "EastwindOutlook", function() return 1 end), nil, "invalid rng")
        eq(Ecology.roll({}, "StarterMeadow", function() return 0 end), nil, "empty")
        eq(Ecology.weight({spawnWeight = math.huge}, "StarterMeadow"), 0, "infinity")
        eq(Ecology.weight({spawnWeight = 0/0}, "StarterMeadow"), 0, "nan")
        eq(Ecology.weight({spawnWeight = -1}, "StarterMeadow"), 0, "negative")
    end)
end

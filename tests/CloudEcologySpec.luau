return function(test, eq)
    local Ecology = require("../src/shared/CloudEcology")
    local catalog = {
        breeze = { element = "Air", spawnWeight = 10 },
        thunder = { element = "Storm", spawnWeight = 10 },
        moss = { element = "Nature", spawnWeight = 10 },
    }
    test("regional habitats give distinct elemental spawn odds", function()
        eq(Ecology.weight(catalog.thunder, "ThunderheadRidge"), 30, "ridge storm")
        eq(Ecology.weight(catalog.thunder, "StarterMeadow"), 4.5, "meadow storm")
        eq(Ecology.weight(catalog.breeze, "EastwindOutlook"), 25, "eastwind air")
        eq(Ecology.weight(catalog.moss, "StarterMeadow"), 22, "meadow nature")
    end)
    test("regional ecology keeps all species available for discovery", function()
        for _, region in ipairs({ "StarterMeadow", "EastwindOutlook", "ThunderheadRidge" }) do
            for _, entry in pairs(catalog) do
                eq(Ecology.weight(entry, region) > 0, true, "species stays available")
            end
        end
    end)
    test("ecology roll is deterministic and region changes outcomes", function()
        eq(Ecology.roll(catalog, "StarterMeadow", function() return 0.5 end), "moss", "meadow middle")
        eq(Ecology.roll(catalog, "ThunderheadRidge", function() return 0.5 end), "thunder", "ridge middle")
        eq(Ecology.roll(catalog, "EastwindOutlook", function() return 0 end), "breeze", "first sorted")
    end)
    test("ecology rejects malformed weights and RNG values", function()
        eq(Ecology.weight({spawnWeight = math.huge}, "StarterMeadow"), 0, "infinite")
        eq(Ecology.weight({spawnWeight = -5}, "StarterMeadow"), 0, "negative")
        eq(Ecology.roll({}, "StarterMeadow", function() return 0.5 end), nil, "empty")
        eq(Ecology.roll(catalog, "StarterMeadow", function() return 1 end), nil, "one out of range")
        eq(Ecology.roll(catalog, "StarterMeadow", function() return 0 / 0 end), nil, "nan")
        eq(Ecology.roll(catalog, "StarterMeadow", function() return -1 end), nil, "negative rng")
    end)
end

-- Server-owned rotating sky weather. Pure logic, deterministic and safe for Luau tests.
local Weather = {}
Weather.PERIOD = 300
Weather.PHASES = { "Clear", "Drizzle", "Gust", "Storm" }
local boosts = {
    Clear = { Air = 1.3, Light = 1.2 },
    Drizzle = { Water = 2, Nature = 1.3 },
    Gust = { Air = 2, Electric = 1.2 },
    Storm = { Electric = 2, Dark = 1.4 },
}
function Weather.phaseAt(seconds)
    if type(seconds) ~= "number" or seconds ~= seconds or seconds < 0 or seconds == math.huge then
        return "Clear"
    end
    return Weather.PHASES[(math.floor(seconds / Weather.PERIOD) % #Weather.PHASES) + 1]
end
function Weather.weightFor(species, phase)
    if type(species) ~= "table" then return 0 end
    local weight = species.spawnWeight
    if type(weight) ~= "number" or weight ~= weight or weight <= 0 or weight == math.huge then return 0 end
    local bonus = (boosts[phase] or boosts.Clear)[species.element] or 1
    return weight * bonus
end
function Weather.adjustedCatalog(catalog, phase)
    local result = {}
    for id, species in pairs(catalog) do
        local copy = {}
        for key, value in pairs(species) do copy[key] = value end
        copy.spawnWeight = Weather.weightFor(species, phase)
        result[id] = copy
    end
    return result
end
return Weather

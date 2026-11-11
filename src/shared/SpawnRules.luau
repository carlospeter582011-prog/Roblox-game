-- Pure weighted species selection for cloud spawns. No Roblox globals; the RNG is injected so
-- tests are deterministic and the server can pass math.random.
local Spawn = {}

local function validWeight(weight)
    return type(weight) == "number" and weight == weight and weight > 0 and weight < math.huge
end

-- species: map of id -> { spawnWeight = number, ... }. rng: function() -> number in [0, 1).
-- Entries without a positive finite spawnWeight never spawn. Returns the chosen id, or nil if
-- nothing is spawnable. Ids are visited in sorted order so a given rng value is reproducible.
function Spawn.rollSpecies(species, rng)
    local ids = {}
    local total = 0
    for id, entry in pairs(species) do
        if validWeight(entry.spawnWeight) then
            table.insert(ids, id)
            total += entry.spawnWeight
        end
    end
    if #ids == 0 then
        return nil
    end
    table.sort(ids)
    local target = rng() * total
    local acc = 0
    for _, id in ipairs(ids) do
        acc += species[id].spawnWeight
        if target < acc then
            return id
        end
    end
    return ids[#ids] -- float rounding edge: target reached the total
end

-- Region layout must match the actual walkable floors in StarterWorld.server.luau.
-- A stable rotation keeps the starter island populated while sending players onward.
function Spawn.regionBounds(sequence)
    if type(sequence) ~= "number" or sequence < 1 or sequence ~= math.floor(sequence) then
        return nil
    end
    local slot = sequence % 7
    if slot == 0 then
        return { name = "SunsetDunes", minX = 430, maxX = 490, minZ = -30, maxZ = 30 }
    elseif slot == 5 then
        return { name = "ThunderheadRidge", minX = 285, maxX = 345, minZ = -30, maxZ = 30 }
    elseif slot == 2 then
        return { name = "EastwindOutlook", minX = 140, maxX = 200, minZ = -30, maxZ = 30 }
    end
    return { name = "StarterMeadow", minX = -55, maxX = 55, minZ = -55, maxZ = 55 }
end

-- Region fast-travel unlocks are derived from persisted catches; no extra save schema.
Spawn.travelDestinations = {
    starter = { requiredCatches = 0, x = 0, y = 5, z = -25 },
    eastwind = { requiredCatches = 25, x = 170, y = 5, z = 0 },
    ridge = { requiredCatches = 75, x = 315, y = 5, z = 0 },
    dunes = { requiredCatches = 100, x = 460, y = 5, z = 0 },
}
function Spawn.canFastTravel(destination, captures)
    local target = type(destination) == "string" and Spawn.travelDestinations[destination] or nil
    return target ~= nil and type(captures) == "number" and captures >= target.requiredCatches
end

return Spawn

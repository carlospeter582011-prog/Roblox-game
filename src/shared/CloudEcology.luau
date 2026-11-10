-- Regional cloud ecology: local habitats influence discoveries without hiding species
-- behind an unavailable Place. Pure, deterministic, server-authoritative rules.
local Ecology = {}
local affinities = {
    StarterMeadow = { Nature = 2.2, Earth = 1.5, Air = 1.4, Storm = 0.45 },
    EastwindOutlook = { Air = 2.5, Light = 1.7, Cosmic = 1.3, Water = 0.7 },
    ThunderheadRidge = { Storm = 3.0, Fire = 1.5, Ice = 1.3, Nature = 0.55 },
}
Ecology.affinities = affinities

local function finite(n)
    return type(n) == "number" and n == n and n < math.huge and n > -math.huge
end

function Ecology.weight(entry, region)
    if type(entry) ~= "table" or not finite(entry.spawnWeight) or entry.spawnWeight <= 0 then
        return 0
    end
    local habitat = affinities[region]
    local multiplier = habitat and habitat[entry.element] or 1
    return entry.spawnWeight * multiplier
end

-- Stable id ordering makes seeded rolls reproducible in regression tests.
-- Invalid RNG values fail closed instead of silently selecting rare clouds.
function Ecology.roll(catalog, region, rng)
    if type(catalog) ~= "table" or type(rng) ~= "function" then return nil end
    local ids, total = {}, 0
    for id, entry in pairs(catalog) do
        if type(id) == "string" then
            local w = Ecology.weight(entry, region)
            if w > 0 and finite(total + w) then
                table.insert(ids, id)
                total += w
            end
        end
    end
    if total <= 0 then return nil end
    table.sort(ids)
    local roll = rng()
    if not finite(roll) or roll < 0 or roll >= 1 then return nil end
    local threshold, accumulated = roll * total, 0
    for _, id in ipairs(ids) do
        accumulated += Ecology.weight(catalog[id], region)
        if threshold < accumulated then return id end
    end
    return ids[#ids]
end
return Ecology

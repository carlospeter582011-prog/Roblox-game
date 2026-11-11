-- Region ecology: species are weighted by elemental habitat, without blocking
-- starter catches or making any catalog species unobtainable.
-- Pure Luau, server-owned inputs. No client-controlled region or rarity.
local Ecology = {}
local affinities = {
    StarterMeadow = { Nature = 2.5, Air = 1.8, Earth = 1.4, Storm = 0.65, Cosmic = 0.5 },
    EastwindOutlook = { Air = 3, Light = 1.7, Water = 1.3, Earth = 0.7, Fire = 0.8 },
    ThunderheadRidge = { Storm = 3.2, Fire = 1.6, Shadow = 1.5, Ice = 1.2, Nature = 0.65 },
}
function Ecology.weight(entry, region)
    if type(entry) ~= "table" then return 0 end
    local weight = entry.spawnWeight
    if type(weight) ~= "number" or weight ~= weight or weight <= 0 or weight == math.huge then return 0 end
    local boost = affinities[region] and affinities[region][entry.element] or 1
    return weight * (boost or 1)
end
function Ecology.roll(catalog, region, rng)
    if type(catalog) ~= "table" or type(rng) ~= "function" then return nil end
    local ids, total = {}, 0
    for id, entry in pairs(catalog) do
        local weight = Ecology.weight(entry, region)
        if type(id) == "string" and weight > 0 and weight < math.huge then
            table.insert(ids, id)
            total += weight
        end
    end
    if total <= 0 or total == math.huge then return nil end
    table.sort(ids)
    local roll = rng()
    if type(roll) ~= "number" or roll ~= roll or roll < 0 or roll >= 1 then return nil end
    local target, cumulative = roll * total, 0
    for _, id in ipairs(ids) do
        cumulative += Ecology.weight(catalog[id], region)
        if target < cumulative then return id end
    end
    return ids[#ids]
end
return Ecology

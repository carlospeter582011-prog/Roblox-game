-- Pure evolution and fusion rules for Catch a Cloud. No Roblox globals.
-- Evolution is based on owned count of a species reaching a threshold; result is a higher-tier same-element species if available.
-- Fusion is a preview only in this slice: two owned species of same element can suggest a rare result.

local Rules = {}

local EVOLUTION_THRESHOLDS = {
    Common = 5,
    Uncommon = 8,
    Rare = 12,
    Epic = 20,
}

function Rules.thresholdFor(rarity)
    return EVOLUTION_THRESHOLDS[rarity] or 999
end

function Rules.canEvolve(speciesId, ownedCount, catalog)
    if type(speciesId) ~= "string" or type(ownedCount) ~= "number" or ownedCount < 1 then return false end
    local entry = catalog[speciesId]
    if not entry or type(entry.rarity) ~= "string" then return false end
    local need = Rules.thresholdFor(entry.rarity)
    return ownedCount >= need
end

function Rules.nextEvolution(speciesId, catalog)
    local entry = catalog[speciesId]
    if not entry or type(entry.element) ~= "string" then return nil end
    local currentRarity = entry.rarity
    local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}
    local idx = 1
    for i, r in ipairs(rarities) do
        if r == currentRarity then idx = i break end
    end
    if idx >= #rarities then return nil end
    local nextRarity = rarities[idx + 1]
    -- Find any same-element species of the next rarity (deterministic: first sorted id)
    local candidates = {}
    for id, other in pairs(catalog) do
        if other.element == entry.element and other.rarity == nextRarity and id ~= speciesId then
            table.insert(candidates, id)
        end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates)
    return candidates[1]
end

function Rules.evolve(speciesId, ownedCount, catalog)
    if not Rules.canEvolve(speciesId, ownedCount, catalog) then return nil, "not ready" end
    local nextId = Rules.nextEvolution(speciesId, catalog)
    if not nextId then return nil, "no path" end
    return nextId, "ok"
end

-- Basic fusion preview: two different owned species of same element.
function Rules.fusionPreview(idA, idB, catalog)
    if idA == idB or type(idA) ~= "string" or type(idB) ~= "string" then return nil end
    local a, b = catalog[idA], catalog[idB]
    if not a or not b or a.element ~= b.element then return nil end
    -- Suggest a higher rarity same-element if possible, else the rarer of the two.
    local targetRarity = a.rarity
    if b.rarity == "Epic" or b.rarity == "Legendary" or b.rarity == "Mythic" then targetRarity = b.rarity end
    local candidates = {}
    for id, other in pairs(catalog) do
        if other.element == a.element and other.rarity == targetRarity and id ~= idA and id ~= idB then
            table.insert(candidates, id)
        end
    end
    if #candidates > 0 then
        table.sort(candidates)
        return candidates[1]
    end
    return idA -- fallback
end

return Rules

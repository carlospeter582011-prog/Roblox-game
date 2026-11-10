-- Pure, deterministic companion selection. Never trust client-reported ownership.
local Rules = {}
function Rules.owned(speciesId, species, catalog)
    return type(speciesId) == "string" and #speciesId <= 48
        and catalog[speciesId] ~= nil and type(species) == "table"
        and type(species[speciesId]) == "number" and species[speciesId] >= 1
end
function Rules.sortedOwned(species, catalog)
    local ids = {}
    for id in pairs(catalog) do
        if Rules.owned(id, species, catalog) then table.insert(ids, id) end
    end
    table.sort(ids)
    return ids
end
function Rules.next(current, species, catalog)
    local ids = Rules.sortedOwned(species, catalog)
    if #ids == 0 then return nil end
    for i, id in ipairs(ids) do
        if id == current then return ids[i % #ids + 1] end
    end
    return ids[1]
end
-- Bond grows when catching clouds while a companion is equipped.
-- A small capped Coin bonus rewards continued play without paid boosts.
function Rules.bondLevel(points)
    if type(points) ~= "number" or points ~= points or points < 0 then return 0 end
    if points >= 100 then return 3 end
    if points >= 40 then return 2 end
    if points >= 10 then return 1 end
    return 0
end
function Rules.advanceBond(points)
    local safe = type(points) == "number" and points == points and points >= 0 and points < 1000000 and math.floor(points) or 0
    return math.min(safe + 1, 1000000)
end
function Rules.bonusCoins(baseCoins, bondPoints)
    if type(baseCoins) ~= "number" or baseCoins ~= baseCoins or baseCoins < 0 or baseCoins == math.huge then return 0 end
    return math.floor(baseCoins * Rules.bondLevel(bondPoints) * 0.02)
end

-- Elemental resonance: an owned equipped companion of the same element grants
-- a modest XP bonus after Bond level 1. No client-provided element or multiplier.
-- The bonus applies to catch XP only, not quest or boss rewards.
function Rules.resonanceXp(baseXp, companionId, targetId, species, catalog, bond)
    if type(baseXp) ~= "number" or baseXp ~= baseXp or baseXp < 0 or baseXp == math.huge or baseXp > 100000 then return 0 end
    if not Rules.owned(companionId, species, catalog) then return 0 end
    local companion, target = catalog[companionId], catalog[targetId]
    if not target or type(companion.element) ~= "string" or companion.element ~= target.element then return 0 end
    local level = Rules.bondLevel(bond and bond[companionId])
    if level == 0 then return 0 end
    return math.floor(baseXp * math.min(level, 3) * 0.05)
end

-- Elemental field ability: Air companions grant a small, earned catch reach bonus.
-- Calculated only from server-owned collection and saved Bond points. This stacks
-- with purchased training but is capped at 3 studs and never changes tool ownership.
function Rules.airReachBonus(companionId, species, catalog, bond)
    if not Rules.owned(companionId, species, catalog) then return 0 end
    local entry = catalog[companionId]
    if entry.element ~= "Air" then return 0 end
    return math.min(3, Rules.bondLevel(bond and bond[companionId]))
end
-- Nature companion discovery instinct: first-ever species catch grants earned XP.
-- Use the pre-catch species collection; duplicates never qualify. This is server-only.
function Rules.natureDiscoveryXp(baseXp, companionId, targetId, species, catalog, bond)
    if type(baseXp) ~= "number" or baseXp ~= baseXp or baseXp < 0 or baseXp == math.huge or baseXp > 100000 then return 0 end
    if not Rules.owned(companionId, species, catalog) or not catalog[targetId] then return 0 end
    if catalog[companionId].element ~= "Nature" then return 0 end
    if type(species[targetId]) == "number" and species[targetId] > 0 then return 0 end
    local level = Rules.bondLevel(bond and bond[companionId])
    return math.floor(baseXp * level * 0.1)
end
return Rules

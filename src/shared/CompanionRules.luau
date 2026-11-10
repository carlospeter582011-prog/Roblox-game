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
return Rules

-- Pure server-side cloud fusion rules. A fusion consumes two spare copies of an
-- owned species, keeps at least one specimen, and strengthens its bond.
-- The caller must persist the returned state under the existing profile session lock.
local Fusion = {}
Fusion.COST_COINS = 75
Fusion.COPIES_CONSUMED = 2
Fusion.BOND_GAIN = 15
Fusion.MAX_BOND = 1000000
local function integer(n, maximum)
    return type(n) == "number" and n == n and n ~= math.huge
        and n ~= -math.huge and n >= 0 and n <= maximum and n == math.floor(n)
end
function Fusion.preview(data, speciesId, catalog)
    if type(data) ~= "table" or type(data.species) ~= "table"
        or type(data.companionBond) ~= "table" or type(catalog) ~= "table"
        or type(speciesId) ~= "string" or not speciesId:match("^[%w_]+$")
        or not catalog[speciesId] then
        return { ok = false, reason = "invalid_species" }
    end
    local count = data.species[speciesId]
    if not integer(count, 100000) or count < Fusion.COPIES_CONSUMED + 1 then
        return { ok = false, reason = "need_spares" }
    end
    if not integer(data.coins, 1e12) or data.coins < Fusion.COST_COINS then
        return { ok = false, reason = "need_coins" }
    end
    local bond = data.companionBond[speciesId] or 0
    if not integer(bond, Fusion.MAX_BOND) then
        return { ok = false, reason = "invalid_bond" }
    end
    if bond >= Fusion.MAX_BOND then
        return { ok = false, reason = "bond_maxed" }
    end
    return { ok = true, cost = Fusion.COST_COINS,
        copies = Fusion.COPIES_CONSUMED,
        bondGain = math.min(Fusion.BOND_GAIN, Fusion.MAX_BOND - bond) }
end
function Fusion.apply(data, speciesId, catalog)
    local result = Fusion.preview(data, speciesId, catalog)
    if not result.ok then return result end
    -- No mutation on failure; copy nested maps so callers can commit atomically.
    local species, bonds = {}, {}
    for k, v in pairs(data.species) do species[k] = v end
    for k, v in pairs(data.companionBond) do bonds[k] = v end
    species[speciesId] -= result.copies
    bonds[speciesId] = (bonds[speciesId] or 0) + result.bondGain
    local updated = {}
    for k, v in pairs(data) do updated[k] = v end
    updated.species, updated.companionBond = species, bonds
    updated.coins -= result.cost
    return { ok = true, data = updated, bondGain = result.bondGain }
end
return Fusion

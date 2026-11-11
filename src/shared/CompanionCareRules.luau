-- Pure server-authoritative companion care transaction. No client-provided rewards.
local Rules = {}
Rules.COST = 30
Rules.BOND_GAIN = 5
Rules.COOLDOWN = 90
Rules.MAX_BOND = 1000000
local function validInt(n, max)
    return type(n) == "number" and n == n and n ~= math.huge and n >= 0
        and n <= max and n == math.floor(n)
end
function Rules.preview(data, catalog, now, lastCare)
    if type(data) ~= "table" or type(catalog) ~= "table" then return nil, "profile" end
    if not validInt(now, 1e12) then return nil, "clock" end
    if lastCare ~= nil then
        if not validInt(lastCare, 1e12) then return nil, "cooldown" end
        if now < lastCare or now - lastCare < Rules.COOLDOWN then return nil, "cooldown" end
    end
    local id = data.companionSpecies
    if type(id) ~= "string" or not catalog[id] or type(data.species) ~= "table"
        or not validInt(data.species[id], 100000) or data.species[id] < 1 then
        return nil, "companion"
    end
    if not validInt(data.coins, 1e12) or data.coins < Rules.COST then return nil, "coins" end
    local bond = type(data.companionBond) == "table" and data.companionBond or {}
    local points = bond[id] or 0
    if not validInt(points, Rules.MAX_BOND) then return nil, "bond" end
    if points >= Rules.MAX_BOND then return nil, "max_bond" end
    return { speciesId = id, coins = data.coins - Rules.COST,
        bond = math.min(Rules.MAX_BOND, points + Rules.BOND_GAIN) }
end
function Rules.apply(data, preview)
    -- Caller must generate preview against the same server-owned profile without yielding.
    if type(data) ~= "table" or type(preview) ~= "table" then return false end
    data.companionBond = data.companionBond or {}
    data.coins = preview.coins
    data.companionBond[preview.speciesId] = preview.bond
    return true
end
return Rules

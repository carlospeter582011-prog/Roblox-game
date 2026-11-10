-- Pure, server-owned duplicate cloud recycling. Always preserve one specimen.
local Rules = {}
Rules.COST = 3
Rules.COINS = 35
Rules.XP = 20
function Rules.choose(species, catalog)
    if type(species) ~= "table" or type(catalog) ~= "table" then return nil end
    local ids = {}
    for id, count in pairs(species) do
        if type(id) == "string" and catalog[id] and type(count) == "number"
            and count == count and count ~= math.huge and count >= Rules.COST + 1
            and count == math.floor(count) then
            table.insert(ids, id)
        end
    end
    table.sort(ids)
    return ids[1]
end
function Rules.apply(profile, catalog)
    if type(profile) ~= "table" or type(profile.species) ~= "table" then return false end
    local id = Rules.choose(profile.species, catalog)
    if not id then return false end
    if type(profile.coins) ~= "number" or type(profile.xp) ~= "number"
        or profile.coins < 0 or profile.xp < 0
        or profile.coins ~= profile.coins or profile.xp ~= profile.xp
        or profile.coins > 1e12 - Rules.COINS or profile.xp > 1e12 - Rules.XP then
        return false
    end
    profile.species[id] -= Rules.COST
    profile.coins += Rules.COINS
    profile.xp += Rules.XP
    return true, id
end
return Rules

-- Server-authoritative exchange of duplicate clouds for Coins.
-- No random rolls or client-supplied species/count/reward; retain one of every species.
local Exchange = {}
local RATES = { Common = 12, Uncommon = 25, Rare = 55, Epic = 110, Legendary = 220, Mythic = 350, Secret = 500 }
Exchange.RATES = RATES

function Exchange.choose(species, catalog)
    if type(species) ~= "table" or type(catalog) ~= "table" then return nil end
    local bestId, bestCount
    for id, count in pairs(species) do
        local entry = catalog[id]
        if type(id) == "string" and entry and RATES[entry.rarity]
            and type(count) == "number" and count == count and count ~= math.huge
            and count >= 2 and count == math.floor(count) then
            if not bestId or count > bestCount or (count == bestCount and id < bestId) then
                bestId, bestCount = id, count
            end
        end
    end
    return bestId
end

function Exchange.apply(profile, catalog)
    if type(profile) ~= "table" or type(profile.species) ~= "table" then return false, "Profile unavailable" end
    local id = Exchange.choose(profile.species, catalog)
    if not id then return false, "No duplicate clouds to exchange" end
    local rate = RATES[catalog[id].rarity]
    if type(profile.coins) ~= "number" or profile.coins ~= profile.coins
        or profile.coins < 0 or profile.coins == math.huge or profile.coins > 999999999 - rate then
        return false, "Wallet limit reached"
    end
    profile.species[id] -= 1
    profile.coins += rate
    return true, id, rate, profile.species[id]
end
return Exchange

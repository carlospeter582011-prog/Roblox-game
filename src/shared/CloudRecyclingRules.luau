-- Pure server-side rules for recycling duplicate clouds into useful progression.
-- This does not change lifetime capture count, quest completion, or mutation records.
local Rules = {}
local payouts = {
    Common = { coins = 12, xp = 8 },
    Uncommon = { coins = 25, xp = 14 },
    Rare = { coins = 48, xp = 24 },
    Epic = { coins = 90, xp = 40 },
    Legendary = { coins = 150, xp = 65 },
    Mythic = { coins = 220, xp = 90 },
    Secret = { coins = 300, xp = 120 },
}
function Rules.quote(speciesId, species, catalog)
    if type(speciesId) ~= "string" or #speciesId > 48
        or type(species) ~= "table" or type(catalog) ~= "table" then
        return nil, "Invalid species"
    end
    local entry = catalog[speciesId]
    if type(entry) ~= "table" or not payouts[entry.rarity] then
        return nil, "Unknown species"
    end
    local owned = species[speciesId]
    if type(owned) ~= "number" or owned ~= owned or owned == math.huge
        or owned ~= math.floor(owned) or owned < 3 then
        return nil, "Keep at least two copies"
    end
    return payouts[entry.rarity]
end
function Rules.recycle(data, speciesId, catalog)
    if type(data) ~= "table" or type(data.coins) ~= "number"
        or type(data.xp) ~= "number" then return false, "Profile unavailable" end
    local quote, reason = Rules.quote(speciesId, data.species, catalog)
    if not quote then return false, reason end
    if data.coins < 0 or data.xp < 0 or data.coins + quote.coins >= 1e12
        or data.xp + quote.xp >= 1e12 then return false, "Wallet limit" end
    data.species[speciesId] -= 1
    data.coins += quote.coins
    data.xp += quote.xp
    return true, quote
end
return Rules

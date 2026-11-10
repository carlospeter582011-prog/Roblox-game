-- Pure cloud species mastery and evolution rules. No Roblox globals.
local Rules = {}

Rules.THRESHOLDS = {
    Common = 40,
    Uncommon = 80,
    Rare = 160,
    Epic = 320,
    Legendary = 640,
    Mythic = 1200,
}

Rules.EVOLUTION_REWARD_COINS = 75
Rules.EVOLUTION_REWARD_XP = 40

function Rules.needed(rarity)
    return Rules.THRESHOLDS[rarity] or 100
end

function Rules.canEvolve(speciesId, mastery, rarity, evolved)
    if type(speciesId) ~= "string" or type(evolved) ~= "table" or evolved[speciesId] then
        return false
    end
    local have = type(mastery) == "table" and mastery[speciesId] or 0
    return type(have) == "number" and have >= Rules.needed(rarity)
end

-- Mutates data. Returns true on success.
function Rules.apply(data, speciesId, rarity)
    if not Rules.canEvolve(speciesId, data.speciesMastery, rarity, data.evolvedSpecies) then
        return false
    end
    data.evolvedSpecies[speciesId] = true
    data.coins = (data.coins or 0) + Rules.EVOLUTION_REWARD_COINS
    data.xp = (data.xp or 0) + Rules.EVOLUTION_REWARD_XP
    return true
end

return Rules

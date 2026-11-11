-- Pure habitat care rules. No Roblox globals.
-- Players spend Coins at a 3D habitat station to increase bond on the equipped companion.
local HabitatRules = {}

HabitatRules.COIN_COST = 25
HabitatRules.BOND_GAIN = 8
HabitatRules.SESSION_COOLDOWN = 60 -- seconds
HabitatRules.MAX_SESSION_USES = 20

function HabitatRules.canUse(coins, companionId, speciesOwned, bondTable, lastUseAt, now, usesThisSession)
    if type(coins) ~= "number" or coins < HabitatRules.COIN_COST then
        return false, "insufficient_coins"
    end
    if type(companionId) ~= "string" or companionId == "" then
        return false, "no_companion"
    end
    if type(speciesOwned) ~= "table" or (speciesOwned[companionId] or 0) < 1 then
        return false, "not_owned"
    end
    if type(usesThisSession) ~= "number" or usesThisSession >= HabitatRules.MAX_SESSION_USES then
        return false, "session_cap"
    end
    if type(lastUseAt) == "number" and type(now) == "number" and (now - lastUseAt) < HabitatRules.SESSION_COOLDOWN then
        return false, "cooldown"
    end
    return true
end

function HabitatRules.apply(coins, bondTable, companionId)
    local newCoins = coins - HabitatRules.COIN_COST
    local current = (bondTable and bondTable[companionId]) or 0
    local newBond = math.min(current + HabitatRules.BOND_GAIN, 1000000)
    return newCoins, newBond
end

return HabitatRules

-- First-time species discovery grants an XP boost once per species per player.
-- Uses persisted species counts, so reconnecting cannot farm the reward.
-- Pure module: no Roblox globals or client-supplied reward values.
local Discovery = {}
local BONUS = { Common = 10, Uncommon = 20, Rare = 35, Epic = 60, Legendary = 100, Mythic = 150 }
function Discovery.bonusXp(species, previousCount)
    if type(species) ~= "table" or type(previousCount) ~= "number"
        or previousCount ~= previousCount or previousCount < 0 or previousCount == math.huge then
        return 0
    end
    if previousCount ~= 0 then return 0 end
    return BONUS[species.rarity] or 0
end
return Discovery

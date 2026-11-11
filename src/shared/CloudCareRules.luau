-- Pure rules for companion care / feeding. No Roblox globals.
local Care = {}

Care.FEED_COST = 25
Care.BOND_GAIN = 5
Care.COOLDOWN_SECONDS = 60
Care.MAX_BOND = 1000000

function Care.canFeed(coins, lastFeedTime, now)
    if type(coins) ~= "number" or coins ~= coins or coins == math.huge or coins < Care.FEED_COST then
        return false, "Need " .. Care.FEED_COST .. " coins"
    end
    if type(lastFeedTime) == "number" and type(now) == "number" and now < lastFeedTime + Care.COOLDOWN_SECONDS then
        return false, "Companion is full. Wait a moment."
    end
    return true
end

function Care.applyFeed(currentBond)
    local bond = type(currentBond) == "number" and math.floor(currentBond) or 0
    if bond < 0 or bond ~= bond or bond == math.huge then bond = 0 end
    return math.min(Care.MAX_BOND, bond + Care.BOND_GAIN)
end

return Care

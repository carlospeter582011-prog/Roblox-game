-- Pure server-side encyclopedia milestone rules. No persistent flags needed:
-- crossing a threshold is detected from the authoritative pre/post-catch collection.
local Milestones = {}
local rewards = {
    { count = 5, coins = 100, xp = 50 },
    { count = 15, coins = 300, xp = 120 },
    { count = 30, coins = 650, xp = 250 },
    { count = 50, coins = 1200, xp = 450 },
    { count = 75, coins = 2000, xp = 700 },
    { count = 100, coins = 3200, xp = 1100 },
    { count = 150, coins = 5000, xp = 1800 },
}
function Milestones.uniqueCount(species, catalog)
    if type(species) ~= "table" or type(catalog) ~= "table" then return 0 end
    local total = 0
    for id in pairs(catalog) do
        local count = species[id]
        if type(count) == "number" and count == count and count >= 1 and count < math.huge then
            total += 1
        end
    end
    return total
end
function Milestones.crossed(previous, current)
    if type(previous) ~= "number" or type(current) ~= "number"
        or previous ~= previous or current ~= current or previous < 0
        or current <= previous or current == math.huge then return 0, 0, nil end
    local coins, xp, highest = 0, 0, nil
    for _, reward in ipairs(rewards) do
        if previous < reward.count and current >= reward.count then
            coins += reward.coins
            xp += reward.xp
            highest = reward.count
        end
    end
    return coins, xp, highest
end
return Milestones

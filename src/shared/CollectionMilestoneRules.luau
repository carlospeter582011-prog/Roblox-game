-- One-time collection discovery milestones, derived from server-owned saved species counts.
-- No extra profile flag: a reward is earned only when the unique species count crosses a threshold.
local Rules = {}
Rules.MILESTONES = {
    { unique = 5, coins = 100, xp = 50 },
    { unique = 10, coins = 250, xp = 100 },
    { unique = 20, coins = 600, xp = 250 },
    { unique = 35, coins = 1200, xp = 500 },
    { unique = 50, coins = 2000, xp = 900 },
    { unique = 75, coins = 4000, xp = 1500 },
    { unique = 100, coins = 6500, xp = 2500 },
    { unique = 150, coins = 12000, xp = 5000 },
}
function Rules.uniqueCount(species, catalog)
    if type(species) ~= "table" or type(catalog) ~= "table" then return 0 end
    local total = 0
    for id in pairs(catalog) do
        local n = species[id]
        if type(n) == "number" and n == n and n >= 1 and n < math.huge then
            total += 1
        end
    end
    return total
end
function Rules.reward(previousCount, newCount)
    if type(previousCount) ~= "number" or type(newCount) ~= "number"
        or previousCount ~= previousCount or newCount ~= newCount
        or previousCount < 0 or newCount < previousCount
        or newCount == math.huge or previousCount == math.huge then
        return 0, 0, nil
    end
    local coins, xp, reached = 0, 0, nil
    for _, milestone in ipairs(Rules.MILESTONES) do
        if previousCount < milestone.unique and newCount >= milestone.unique then
            coins += milestone.coins
            xp += milestone.xp
            reached = milestone.unique
        end
    end
    return coins, xp, reached
end
return Rules

-- Deterministic, persistent species mastery milestones.
-- No additional profile fields: awards are derived from the saved per-species catch count.
-- Rewards are granted only when a successful catch crosses a milestone.
local Mastery = {}
Mastery.MILESTONES = {
    { catches = 5, coins = 40, xp = 25 },
    { catches = 15, coins = 120, xp = 75 },
    { catches = 30, coins = 300, xp = 150 },
}
function Mastery.reward(previousCount, nextCount)
    if type(previousCount) ~= "number" or previousCount ~= previousCount
        or previousCount < 0 or previousCount == math.huge
        or type(nextCount) ~= "number" or nextCount ~= nextCount
        or nextCount ~= previousCount + 1 then
        return 0, 0, nil
    end
    for index, milestone in ipairs(Mastery.MILESTONES) do
        if previousCount < milestone.catches and nextCount >= milestone.catches then
            return milestone.coins, milestone.xp, index
        end
    end
    return 0, 0, nil
end
function Mastery.level(count)
    if type(count) ~= "number" or count ~= count or count < 0 then return 0 end
    local level = 0
    for index, milestone in ipairs(Mastery.MILESTONES) do
        if count >= milestone.catches then level = index end
    end
    return level
end
return Mastery

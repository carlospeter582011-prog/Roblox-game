-- Pure, server-authoritative repeat-catch mastery milestones.
-- Awarded only when a species count crosses a threshold; persisted count prevents farming by rejoin.
local Mastery = {}
Mastery.milestones = {
    { catches = 5, coins = 40, xp = 25 },
    { catches = 15, coins = 120, xp = 75 },
    { catches = 30, coins = 300, xp = 180 },
    { catches = 60, coins = 700, xp = 400 },
}
local function validCount(n)
    return type(n) == "number" and n == n and n >= 0 and n < math.huge
        and n == math.floor(n) and n <= 1000000000
end
function Mastery.reward(previous, current)
    if not validCount(previous) or not validCount(current) or current ~= previous + 1 then
        return 0, 0, nil
    end
    for _, tier in ipairs(Mastery.milestones) do
        if current == tier.catches then
            return tier.coins, tier.xp, tier.catches
        end
    end
    return 0, 0, nil
end
return table.freeze(Mastery)

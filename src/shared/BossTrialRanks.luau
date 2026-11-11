-- Server-side performance ranks for repeatable boss catch trials.
-- Rewards skillful speed without any paid boost, client timestamps or extra DataStore fields.
local Ranks = {}
function Ranks.evaluate(duration, limit, baseCoins, baseXP)
    if type(duration) ~= "number" or type(limit) ~= "number"
        or type(baseCoins) ~= "number" or type(baseXP) ~= "number"
        or duration ~= duration or limit ~= limit or baseCoins ~= baseCoins or baseXP ~= baseXP
        or duration < 0 or limit <= 0 or duration > limit
        or baseCoins < 0 or baseXP < 0 or baseCoins > 100000 or baseXP > 100000 then
        return nil
    end
    local fraction = duration / limit
    local rank, bonus = "Bronze", 0
    if fraction <= 0.4 then
        rank, bonus = "Gold", 0.25
    elseif fraction <= 0.7 then
        rank, bonus = "Silver", 0.1
    end
    return rank, math.floor(baseCoins * bonus), math.floor(baseXP * bonus)
end
return Ranks

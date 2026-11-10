-- Server-authoritative repeat-catch mastery: small, capped XP growth for learning a species.
-- Uses the existing saved species counts; no additional profile fields or client input.
local Mastery = {}
local THRESHOLDS = { 5, 15, 40, 100 }
function Mastery.rank(previousCatches)
    if type(previousCatches) ~= "number" or previousCatches ~= previousCatches
        or previousCatches == math.huge or previousCatches < 0 then return 0 end
    local count = math.floor(previousCatches)
    local rank = 0
    for _, threshold in ipairs(THRESHOLDS) do
        if count >= threshold then rank += 1 end
    end
    return rank
end
function Mastery.bonusXp(baseXp, previousCatches)
    if type(baseXp) ~= "number" or baseXp ~= baseXp or baseXp == math.huge
        or baseXp < 0 or baseXp > 100000 then return 0 end
    -- 5% per rank, at most 20%; calculate before the new catch is counted.
    return math.floor(baseXp * Mastery.rank(previousCatches) * 0.05)
end
return Mastery

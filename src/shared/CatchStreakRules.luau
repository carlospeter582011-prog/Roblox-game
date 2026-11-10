-- Session-only momentum rewards for successful catches; no remote or saved streak to exploit.
-- A failed catch never advances momentum. Streak expires after 45 seconds.
local Rules = {}
Rules.WINDOW = 45
Rules.CAP = 10

function Rules.next(previous, lastTime, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now < 0 then return 1 end
    if type(previous) ~= "number" or previous ~= previous or previous < 1
        or type(lastTime) ~= "number" or lastTime ~= lastTime
        or now < lastTime or now - lastTime > Rules.WINDOW then
        return 1
    end
    return math.min(math.floor(previous) + 1, Rules.CAP)
end

function Rules.bonusXp(streak, baseXp)
    if type(streak) ~= "number" or streak ~= streak or streak < 1
        or type(baseXp) ~= "number" or baseXp ~= baseXp or baseXp < 0
        or baseXp == math.huge or baseXp > 100000 then return 0 end
    -- Every third consecutive catch rewards 10%, capped at 30%.
    local tiers = math.min(math.floor(streak / 3), 3)
    return math.floor(baseXp * tiers * 0.1)
end
return Rules

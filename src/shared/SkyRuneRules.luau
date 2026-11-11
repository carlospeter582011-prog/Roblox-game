-- Pure, deterministic per-player rune puzzle policy. No Roblox globals.
local Rules = {}
Rules.TIME_LIMIT = 40
Rules.RETRY_COOLDOWN = 12
Rules.RUNE_COUNT = 3
function Rules.sequence(userId, round)
    if type(userId) ~= "number" or userId < 1 or userId ~= math.floor(userId)
        or type(round) ~= "number" or round < 1 or round ~= math.floor(round) then return nil end
    local offset = (userId + round) % Rules.RUNE_COUNT
    return { 1 + offset, 1 + (offset + 1) % 3, 1 + (offset + 2) % 3 }
end
function Rules.advance(sequence, step, rune, startedAt, now)
    if type(sequence) ~= "table" or type(step) ~= "number" or step ~= math.floor(step)
        or step < 1 or step > 3 or type(rune) ~= "number" or rune ~= math.floor(rune)
        or rune < 1 or rune > 3 or type(startedAt) ~= "number" or type(now) ~= "number"
        or now < startedAt or now - startedAt > Rules.TIME_LIMIT then return "expired", 1 end
    if rune ~= sequence[step] then return "wrong", 1 end
    if step == 3 then return "complete", 4 end
    return "progress", step + 1
end
return Rules

-- Pure deterministic rules for a personal three-glyph weather dial puzzle.
local Rules = {}
Rules.GLYPHS = { "Sun", "Rain", "Wind" }
Rules.WINDOW = 75
Rules.COOLDOWN = 300
Rules.REWARD_COINS = 85
Rules.REWARD_XP = 45

function Rules.sequence(userId, round)
    if type(userId) ~= "number" or userId < 1 or userId ~= math.floor(userId) then return nil end
    if type(round) ~= "number" or round < 0 or round ~= math.floor(round) then return nil end
    local shift = (userId + round) % 3
    return { Rules.GLYPHS[shift + 1], Rules.GLYPHS[(shift + 1) % 3 + 1], Rules.GLYPHS[(shift + 2) % 3 + 1] }
end

function Rules.advance(sequence, step, glyph, startedAt, now)
    if type(sequence) ~= "table" or type(step) ~= "number" or type(now) ~= "number"
        or type(startedAt) ~= "number" or now ~= now or startedAt ~= startedAt
        or now < startedAt or now - startedAt > Rules.WINDOW then
        return 0, "expired"
    end
    if step < 1 or step > 3 or step ~= math.floor(step) then return 0, "invalid" end
    if glyph ~= sequence[step] then return 1, "reset" end
    if step == 3 then return 4, "complete" end
    return step + 1, "progress"
end

function Rules.ready(now, nextAllowed)
    return type(now) == "number" and now == now and now >= (nextAllowed or 0)
end

return Rules

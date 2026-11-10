-- Pure, server-authoritative ordered rune puzzle logic. No client-supplied rewards.
local Rules = {}
Rules.ORDER = { 2, 4, 1, 3 }
Rules.TIME_LIMIT = 50
Rules.COOLDOWN = 180
Rules.REWARD_COINS = 60
Rules.REWARD_XP = 35
function Rules.step(state, rune, now)
    if type(rune) ~= "number" or rune ~= math.floor(rune) or rune < 1 or rune > 4 then
        return state, "invalid"
    end
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then
        return state, "invalid"
    end
    state = state or { index = 1, started = nil, readyAt = 0 }
    if now < state.readyAt then return state, "cooldown" end
    if state.started and now - state.started > Rules.TIME_LIMIT then
        state = { index = 1, started = nil, readyAt = state.readyAt }
    end
    if rune ~= Rules.ORDER[state.index] then
        return { index = 1, started = nil, readyAt = state.readyAt }, "reset"
    end
    local started = state.started or now
    if state.index == #Rules.ORDER then
        return { index = 1, started = nil, readyAt = now + Rules.COOLDOWN }, "complete"
    end
    return { index = state.index + 1, started = started, readyAt = state.readyAt }, "progress"
end
return table.freeze(Rules)

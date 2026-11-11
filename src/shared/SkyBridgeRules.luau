-- Pure server-side sequence rules for the Sky Bridge puzzle.
local Rules = {}
Rules.SEQUENCE = { 2, 4, 1, 3 }
Rules.WINDOW = 35
Rules.BRIDGE_DURATION = 75
Rules.RETRY_DELAY = 8
function Rules.step(state, pad, now)
    if type(now) ~= "number" or now ~= now or now == math.huge then return state, "invalid" end
    if type(pad) ~= "number" or pad % 1 ~= 0 or pad < 1 or pad > 4 then return state, "invalid" end
    state = state or { index = 1, started = nil, unlockedUntil = 0, retryAt = 0 }
    if now < state.unlockedUntil then return state, "open" end
    if now < state.retryAt then return state, "wait" end
    local index = state.index
    if state.started and now - state.started > Rules.WINDOW then index = 1 end
    if pad ~= Rules.SEQUENCE[index] then
        return { index = 1, started = nil, unlockedUntil = 0, retryAt = now + Rules.RETRY_DELAY }, "wrong"
    end
    if index == #Rules.SEQUENCE then
        return { index = 1, started = nil, unlockedUntil = now + Rules.BRIDGE_DURATION, retryAt = 0 }, "unlocked"
    end
    return { index = index + 1, started = index == 1 and now or state.started, unlockedUntil = 0, retryAt = 0 }, "progress"
end
return Rules

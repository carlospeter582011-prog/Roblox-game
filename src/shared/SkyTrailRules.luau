-- Pure server-owned sky trail race validation. No client timing or checkpoints trusted.
local R = {}
R.TIME_LIMIT = 180
R.REPLAY_COOLDOWN = 60
R.CHECKPOINTS = 3
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function R.begin(previous, now)
    if not finite(now) or now < 0 then return nil, "invalid_time" end
    if previous and finite(previous.cooldownUntil) and now < previous.cooldownUntil then
        return nil, "cooldown"
    end
    return { startedAt = now, nextCheckpoint = 1, cooldownUntil = now + R.REPLAY_COOLDOWN }, "started"
end
function R.advance(state, checkpoint, now)
    if type(state) ~= "table" or not finite(now) or not finite(state.startedAt)
        or not finite(checkpoint) or checkpoint ~= math.floor(checkpoint) then return nil, "invalid" end
    if now < state.startedAt or now - state.startedAt > R.TIME_LIMIT then return nil, "expired" end
    if checkpoint ~= state.nextCheckpoint or checkpoint < 1 or checkpoint > R.CHECKPOINTS then
        return nil, "out_of_order"
    end
    local nextState = {
        startedAt = state.startedAt,
        nextCheckpoint = checkpoint + 1,
        cooldownUntil = state.cooldownUntil,
    }
    if checkpoint == R.CHECKPOINTS then
        nextState.finished = true
        nextState.elapsed = now - state.startedAt
        nextState.cooldownUntil = now + R.REPLAY_COOLDOWN
        return nextState, "finished"
    end
    return nextState, "checkpoint"
end
return R

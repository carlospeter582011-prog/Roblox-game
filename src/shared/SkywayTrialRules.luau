-- Pure, deterministic checkpoint challenge rules. No client-controlled rewards.
local Rules = {}
Rules.CHECKPOINTS = 4
Rules.TIME_LIMIT = 55
Rules.COOLDOWN = 90
Rules.BOOST_SECONDS = 18

function Rules.advance(state, checkpoint, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return nil, "invalid_time" end
    if type(checkpoint) ~= "number" or checkpoint % 1 ~= 0 or checkpoint < 1 or checkpoint > Rules.CHECKPOINTS then return nil, "invalid_checkpoint" end
    state = state or { next = 1, started = nil, cooldownUntil = 0 }
    if now < (state.cooldownUntil or 0) then return state, "cooldown" end
    if state.started and now - state.started > Rules.TIME_LIMIT then
        state = { next = 1, started = nil, cooldownUntil = state.cooldownUntil or 0 }
    end
    if checkpoint ~= state.next then return state, "wrong_order" end
    if checkpoint == 1 then
        state.started = now
    end
    if checkpoint == Rules.CHECKPOINTS then
        return { next = 1, started = nil, cooldownUntil = now + Rules.COOLDOWN }, "completed"
    end
    return { next = checkpoint + 1, started = state.started, cooldownUntil = state.cooldownUntil or 0 }, "progress"
end

return Rules

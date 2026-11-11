-- Pure server-side rules for the repeatable Sky Ring Sprint.
local Rules = {}
Rules.CHECKPOINTS = 5
Rules.TIME_LIMIT = 90
Rules.RETRY_DELAY = 8
function Rules.advance(state, checkpoint, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return nil, "invalid_time" end
    if type(checkpoint) ~= "number" or checkpoint % 1 ~= 0 or checkpoint < 1 or checkpoint > Rules.CHECKPOINTS then return nil, "invalid_checkpoint" end
    state = state or {}
    if checkpoint == 1 then
        if state.started and now - state.started < Rules.TIME_LIMIT then return nil, "already_running" end
        if state.finished and now - state.finished < Rules.RETRY_DELAY then return nil, "cooldown" end
        return { started = now, next = 2, best = state.best, finished = state.finished }, "started"
    end
    if not state.started or state.next ~= checkpoint then return nil, "wrong_order" end
    local elapsed = now - state.started
    if elapsed < 0 or elapsed > Rules.TIME_LIMIT then return nil, "expired" end
    if checkpoint == Rules.CHECKPOINTS then
        local best = state.best
        if not best or elapsed < best then best = elapsed end
        return { best = best, finished = now }, "completed", elapsed
    end
    return { started = state.started, next = checkpoint + 1, best = state.best, finished = state.finished }, "advanced"
end
return Rules

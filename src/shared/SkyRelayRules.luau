-- Pure server-authoritative relay timing and checkpoint validation.
local Rules = {}
Rules.CHECKPOINTS = 3
Rules.TIME_LIMIT = 100
Rules.RESTART_COOLDOWN = 8
Rules.MIN_SPLIT = 0.25
function Rules.start(previous, now)
    if type(now) ~= "number" or now ~= now or now < 0 then return nil, "Invalid clock" end
    if previous and now - previous.lastStart < Rules.RESTART_COOLDOWN then return nil, "Wait before restarting" end
    return { index = 0, started = now, lastSplit = now, lastStart = now }, nil
end
function Rules.advance(state, checkpoint, now)
    if type(state) ~= "table" or type(now) ~= "number" or now ~= now or now < state.started then return nil, "Invalid run" end
    if type(checkpoint) ~= "number" or checkpoint ~= math.floor(checkpoint) or checkpoint ~= state.index + 1 or checkpoint > Rules.CHECKPOINTS then return nil, "Wrong checkpoint order" end
    if now - state.started > Rules.TIME_LIMIT then return nil, "Time expired" end
    if now - state.lastSplit < Rules.MIN_SPLIT then return nil, "Too fast" end
    local updated = { index = checkpoint, started = state.started, lastSplit = now, lastStart = state.lastStart }
    return updated, checkpoint == Rules.CHECKPOINTS and now - state.started or nil
end
return Rules

-- Pure rules for a repeatable, server-validated sky sprint activity.
local Rules = {}
Rules.CHECKPOINTS = 3
Rules.MAX_DISTANCE = 15
Rules.TIME_LIMIT = 90
Rules.REWARD_COINS = 35
Rules.REWARD_XP = 20
Rules.REPLAY_COOLDOWN = 180

function Rules.advance(state, checkpoint, distance, now)
    if type(checkpoint) ~= "number" or checkpoint ~= math.floor(checkpoint)
        or checkpoint < 1 or checkpoint > Rules.CHECKPOINTS then return nil, "Invalid checkpoint" end
    if type(distance) ~= "number" or distance ~= distance or distance < 0
        or distance == math.huge or distance > Rules.MAX_DISTANCE then return nil, "Too far" end
    if type(now) ~= "number" or now ~= now or now == math.huge then return nil, "Invalid time" end
    state = state or { next = 1, started = nil, cooldownUntil = -math.huge }
    if now < (state.cooldownUntil or 0) then return nil, "Race cooling down" end
    if checkpoint ~= state.next then return nil, "Wrong checkpoint order" end
    if checkpoint == 1 then
        return { next = 2, started = now, cooldownUntil = state.cooldownUntil }, "Started"
    end
    if type(state.started) ~= "number" or now < state.started
        or now - state.started > Rules.TIME_LIMIT then
        return nil, "Race expired; restart at checkpoint 1"
    end
    if checkpoint == Rules.CHECKPOINTS then
        return { next = 1, started = nil, cooldownUntil = now + Rules.REPLAY_COOLDOWN }, "Finished"
    end
    return { next = checkpoint + 1, started = state.started, cooldownUntil = state.cooldownUntil }, "Checkpoint"
end
return Rules

-- Pure server-side sequential race rules. No Roblox globals.
local Rules = {}
Rules.checkpoints = 5
Rules.limitSeconds = 95
Rules.cooldownSeconds = 180
Rules.rewardCoins = 140
Rules.rewardXP = 80

function Rules.start(now, lastFinish)
    if type(now) ~= "number" or now ~= now or now == math.huge then return nil, "invalid_clock" end
    if type(lastFinish) == "number" and now < lastFinish + Rules.cooldownSeconds then
        return nil, "cooldown"
    end
    return { started = now, next = 1 }, nil
end

function Rules.advance(state, checkpoint, now)
    if type(state) ~= "table" or type(now) ~= "number" or now ~= now
        or type(checkpoint) ~= "number" or checkpoint ~= math.floor(checkpoint) then
        return "invalid"
    end
    if now < state.started or now - state.started > Rules.limitSeconds then return "expired" end
    if checkpoint ~= state.next then return "out_of_order" end
    if checkpoint == Rules.checkpoints then
        -- A server-observed minimum traversal time makes instantaneous completion invalid.
        if now - state.started < 4 then return "too_fast" end
        return "finished"
    end
    state.next += 1
    return "advanced"
end
return Rules

-- Pure server-owned race rules. All timestamps are monotonic server clock values.
local Race = {}
Race.seconds = 120
Race.cooldown = 90
Race.checkpoints = 5
Race.maxDistance = 13
Race.rewards = { coins = 130, xp = 70 }
function Race.validDistance(distance)
    return type(distance) == "number" and distance == distance and distance >= 0 and distance < math.huge and distance <= Race.maxDistance
end
function Race.advance(state, checkpoint, now, distance)
    if type(state) ~= "table" or type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return false, "invalid" end
    if not Race.validDistance(distance) then return false, "range" end
    if type(checkpoint) ~= "number" or checkpoint ~= math.floor(checkpoint) or checkpoint < 1 or checkpoint > Race.checkpoints then return false, "checkpoint" end
    if now < state.started or now - state.started > Race.seconds then return false, "expired" end
    if checkpoint ~= state.next then return false, "order" end
    state.next += 1
    return true, state.next > Race.checkpoints and "finished" or "progress"
end
return Race

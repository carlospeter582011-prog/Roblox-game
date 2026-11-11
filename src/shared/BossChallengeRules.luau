-- Pure rules for repeatable, timed boss catch challenges.
local Boss = {}
Boss.challenges = {
    meadow = { name = "Meadow Warden", requiredCatches = 0, goal = 3, seconds = 90, rewardCoins = 75, rewardXP = 40 },
    eastwind = { name = "Wind Guardian", requiredCatches = 25, goal = 5, seconds = 120, rewardCoins = 175, rewardXP = 85 },
    ridge = { name = "Stormheart Titan", requiredCatches = 75, goal = 7, seconds = 150, rewardCoins = 350, rewardXP = 150 },
}
function Boss.canStart(id, catches)
    local challenge = type(id) == "string" and Boss.challenges[id] or nil
    return challenge ~= nil and type(catches) == "number" and catches >= challenge.requiredCatches
end
function Boss.progress(startCatches, currentCatches, goal)
    if type(startCatches) ~= "number" or type(currentCatches) ~= "number"
        or type(goal) ~= "number" or goal < 1 then return 0 end
    return math.min(goal, math.max(0, currentCatches - startCatches))
end
-- Three escalating stages, derived only from server-observed catch progress.
-- Stage 1 is opening, stage 2 is pressure, stage 3 is final push.
function Boss.phase(progress, goal)
    if type(progress) ~= "number" or type(goal) ~= "number" or goal < 1 then return 1 end
    if progress >= math.ceil(goal * 2 / 3) then return 3 end
    if progress >= math.ceil(goal / 3) then return 2 end
    return 1
end
function Boss.phaseMessage(phase, name)
    if phase == 2 then return name .. " is gathering storm energy! Keep catching!" end
    if phase == 3 then return name .. " final phase! Finish the trial!" end
    return name .. " challenge started!"
end
-- Timed medals reward mastery of existing boss encounters, without random loot.
-- Only server-observed elapsed time and the configured challenge duration count.
function Boss.medal(id, elapsed)
    local c = type(id) == "string" and Boss.challenges[id] or nil
    if not c or type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < 0 or elapsed == math.huge or elapsed > c.seconds then
        return 0, 0, 0
    end
    local fraction = elapsed / c.seconds
    local rank = fraction <= 0.4 and 3 or (fraction <= 0.7 and 2 or 1)
    return rank, math.floor(c.rewardCoins * rank * 0.1), math.floor(c.rewardXP * rank * 0.1)
end
function Boss.reward(id)
    local challenge = type(id) == "string" and Boss.challenges[id] or nil
    if not challenge then return nil, nil end
    return challenge.rewardCoins, challenge.rewardXP
end
function Boss.status(startCatches, currentCatches, goal, deadline, now)
    if type(deadline) ~= "number" or type(now) ~= "number" then return "invalid" end
    if now > deadline then return "expired" end
    if Boss.progress(startCatches, currentCatches, goal) >= goal then return "complete" end
    return "active"
end
return Boss

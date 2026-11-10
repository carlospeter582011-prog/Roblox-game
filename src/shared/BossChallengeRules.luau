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

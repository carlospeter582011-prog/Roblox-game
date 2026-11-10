-- Pure rules for repeatable, timed boss catch challenges.
local Boss = {}
Boss.challenges = {
    meadow = { name = "Meadow Warden", requiredCatches = 0, goal = 3, seconds = 90 },
    eastwind = { name = "Wind Guardian", requiredCatches = 25, goal = 5, seconds = 120 },
    ridge = { name = "Stormheart Titan", requiredCatches = 75, goal = 7, seconds = 150 },
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
function Boss.status(startCatches, currentCatches, goal, deadline, now)
    if type(deadline) ~= "number" or type(now) ~= "number" then return "invalid" end
    if now > deadline then return "expired" end
    if Boss.progress(startCatches, currentCatches, goal) >= goal then return "complete" end
    return "active"
end
return Boss

-- Pure, deterministic rules for a shared server-local cloud-catching beacon event.
local Rules = {}
Rules.GOAL = 12
Rules.DURATION = 180
Rules.REJOIN_COOLDOWN = 240
Rules.MIN_CONTRIBUTION = 2
function Rules.progress(startCatches, currentCatches)
    if type(startCatches) ~= "number" or type(currentCatches) ~= "number"
        or startCatches ~= startCatches or currentCatches ~= currentCatches
        or startCatches == math.huge or currentCatches == math.huge then return 0 end
    return math.max(0, math.min(100000, math.floor(currentCatches) - math.floor(startCatches)))
end
function Rules.status(total, deadline, now)
    if type(total) ~= "number" or type(deadline) ~= "number" or type(now) ~= "number"
        or deadline ~= deadline or now ~= now then return "invalid" end
    if now > deadline then return "expired" end
    if total >= Rules.GOAL then return "complete" end
    return "active"
end
function Rules.eligible(contribution)
    return type(contribution) == "number" and contribution >= Rules.MIN_CONTRIBUTION
end
return Rules

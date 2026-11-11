-- Pure server-side crystal discovery policy. No Roblox services: testable in Luau CI.
local Rules = {}
Rules.MAX_CRYSTALS = 18
Rules.MAX_DISTANCE = 13
Rules.DISCOVERY_COINS = 10
Rules.DISCOVERY_XP = 5

-- Fixed, non-random reward; only award after a first-time server-side discovery.
function Rules.reward(index, alreadyDiscovered)
    if type(index) ~= "number" or index ~= math.floor(index)
        or index < 1 or index > Rules.MAX_CRYSTALS or alreadyDiscovered == true then
        return 0, 0
    end
    return Rules.DISCOVERY_COINS, Rules.DISCOVERY_XP
end

function Rules.canDiscover(index, distance, alreadyDiscovered, profileReady)
    if type(index) ~= "number" or index ~= math.floor(index)
        or index < 1 or index > Rules.MAX_CRYSTALS then
        return false
    end
    if type(distance) ~= "number" or distance ~= distance
        or distance < 0 or distance == math.huge or distance > Rules.MAX_DISTANCE then
        return false
    end
    return profileReady == true and alreadyDiscovered ~= true
end

function Rules.count(discovered)
    local total = 0
    for index, value in pairs(discovered) do
        if value == true and type(index) == "number"
            and index >= 1 and index <= Rules.MAX_CRYSTALS
            and index == math.floor(index) then
            total += 1
        end
    end
    return total
end

-- One-time exploration milestones. Discovery state already persists in the player profile,
-- so the transition across a threshold is the idempotency key (no new save field).
Rules.MILESTONES = {
    [3] = { coins = 50, xp = 20 },
    [6] = { coins = 100, xp = 40 },
    [12] = { coins = 250, xp = 100 },
    [18] = { coins = 500, xp = 200 },
}

function Rules.milestoneReward(before, after)
    if type(before) ~= "number" or type(after) ~= "number"
        or before ~= math.floor(before) or after ~= math.floor(after)
        or before < 0 or after < before or after > Rules.MAX_CRYSTALS then
        return 0, 0, nil
    end
    local coins, xp, reached = 0, 0, nil
    for threshold, prize in pairs(Rules.MILESTONES) do
        if before < threshold and after >= threshold then
            coins += prize.coins
            xp += prize.xp
            reached = math.max(reached or 0, threshold)
        end
    end
    return coins, xp, reached
end

return Rules

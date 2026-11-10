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

-- One-time constellation discoveries. The persistent crystal set is the receipt:
-- crossing a threshold is only possible once because each crystal index is immutable.
-- No separate claim flag, daily reset or client-provided count is trusted.
Rules.MILESTONES = {
    [6] = { coins = 150, xp = 75 },
    [12] = { coins = 400, xp = 200 },
    [18] = { coins = 900, xp = 450 },
}

function Rules.constellationReward(before, after)
    if type(before) ~= "number" or type(after) ~= "number"
        or before ~= before or after ~= after
        or before ~= math.floor(before) or after ~= math.floor(after)
        or before < 0 or after > Rules.MAX_CRYSTALS or after ~= before + 1 then
        return 0, 0, nil
    end
    local milestone = Rules.MILESTONES[after]
    if not milestone then return 0, 0, nil end
    return milestone.coins, milestone.xp, after
end

return Rules

-- Pure server-side crystal discovery policy. No Roblox services: testable in Luau CI.
local Rules = {}
Rules.MAX_CRYSTALS = 18
Rules.MAX_DISTANCE = 13

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

return Rules

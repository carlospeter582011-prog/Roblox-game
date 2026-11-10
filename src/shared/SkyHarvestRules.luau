-- Pure harvest rules. Server chooses node, position and timestamp.
local Rules = {}
Rules.COOLDOWN = 180
Rules.MAX_DISTANCE = 12
Rules.NODES = {
    meadow = { coins = 12, xp = 8, minCaptures = 0 },
    eastwind = { coins = 22, xp = 12, minCaptures = 10 },
    ridge = { coins = 35, xp = 18, minCaptures = 25 },
}
local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
function Rules.canHarvest(nodeId, distance, captures, now, lastAt, ready)
    local node = Rules.NODES[nodeId]
    if not node or ready ~= true or not finite(distance) or distance < 0
        or distance > Rules.MAX_DISTANCE or not finite(captures) or captures < node.minCaptures
        or not finite(now) or now < 0 then
        return false
    end
    if lastAt ~= nil then
        if not finite(lastAt) or now < lastAt or now - lastAt < Rules.COOLDOWN then
            return false
        end
    end
    return true
end
function Rules.reward(nodeId)
    local node = Rules.NODES[nodeId]
    if not node then return nil end
    return node.coins, node.xp
end
return table.freeze(Rules)

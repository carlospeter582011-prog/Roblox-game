-- Pure rules for the reusable Sky Compass cloud-tracking activity.
local Rules = {}
Rules.RANGE = 180
Rules.COOLDOWN = 25
Rules.MARK_SECONDS = 9
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.canScan(now, lastScan, alive, ready)
    if not finite(now) or not alive or not ready then return false end
    if lastScan ~= nil and (not finite(lastScan) or now - lastScan < Rules.COOLDOWN) then return false end
    return true
end
-- Accept distances only from the server; never accept a cloud ID or distance from clients.
function Rules.nearest(distances)
    if type(distances) ~= "table" then return nil end
    local bestId, bestDistance = nil, Rules.RANGE + 1
    for id, distance in pairs(distances) do
        if type(id) == "string" and #id > 0 and #id <= 24
            and finite(distance) and distance >= 0 and distance <= Rules.RANGE
            and (distance < bestDistance or (distance == bestDistance and (bestId == nil or id < bestId))) then
            bestId, bestDistance = id, distance
        end
    end
    return bestId, bestId and bestDistance or nil
end
return Rules

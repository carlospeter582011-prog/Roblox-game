-- Pure, server-owned traversal rules; no Roblox globals.
local Rules = {}
Rules.DURATION = 7
Rules.COOLDOWN = 12
Rules.MAX_DISTANCE = 14
Rules.STATIONS = {
    meadow = { x = -42, y = 2, z = 38, requiredCatches = 0, jumpPower = 88, jumpHeight = 17 },
    eastwind = { x = 178, y = 2, z = 32, requiredCatches = 12, jumpPower = 102, jumpHeight = 21 },
    ridge = { x = 326, y = 2, z = 27, requiredCatches = 45, jumpPower = 116, jumpHeight = 25 },
}
function Rules.canActivate(id, captures, distance, alive, ready, now, lastUsed)
    local station = type(id) == "string" and Rules.STATIONS[id]
    if not station or ready ~= true or alive ~= true then return false end
    if type(captures) ~= "number" or captures ~= captures or captures < station.requiredCatches then return false end
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.MAX_DISTANCE then return false end
    if type(now) ~= "number" or now ~= now or now == math.huge then return false end
    if lastUsed ~= nil and (type(lastUsed) ~= "number" or now < lastUsed or now - lastUsed < Rules.COOLDOWN) then return false end
    return true
end
return table.freeze(Rules)

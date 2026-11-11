-- Pure, server-owned cooperative lantern rules. No player-supplied rewards.
local Rules = {}
Rules.WINDOW = 45
Rules.BOOST_SECONDS = 60
Rules.COOLDOWN = 120
Rules.MAX_DISTANCE = 14
Rules.REQUIRED_PLAYERS = 2
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.canActivate(index, distance, now, startedAt, nextIndex, cooldownUntil)
    if not finite(index) or index ~= math.floor(index) or index < 1 or index > 3 then return false end
    if not finite(distance) or distance < 0 or distance > Rules.MAX_DISTANCE then return false end
    if not finite(now) or now < 0 then return false end
    if not finite(cooldownUntil) or now < cooldownUntil then return false end
    if not finite(nextIndex) or nextIndex < 1 or nextIndex > 3 then return false end
    if index ~= nextIndex then return false end
    if nextIndex > 1 and (not finite(startedAt) or now < startedAt or now - startedAt > Rules.WINDOW) then return false end
    return true
end
function Rules.canComplete(uniqueParticipants)
    return type(uniqueParticipants) == "number" and uniqueParticipants >= Rules.REQUIRED_PLAYERS
        and uniqueParticipants == math.floor(uniqueParticipants) and uniqueParticipants < math.huge
end
return Rules

-- Pure server-side exploration trail validation; session-only progress, no remote trust.
local Trail = {}
Trail.points = {
    { x = 12, y = 9, z = -18 },
    { x = 38, y = 9, z = 14 },
    { x = 165, y = 9, z = -8 },
}
Trail.MAX_DISTANCE = 14
Trail.MIN_SEGMENT_SECONDS = 3
Trail.RESTART_SECONDS = 45
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Trail.canVisit(index, nextIndex, elapsed, distance, ready)
    return ready == true and type(index) == "number" and index == nextIndex
        and index >= 1 and index <= #Trail.points and finite(distance)
        and distance <= Trail.MAX_DISTANCE and finite(elapsed)
        and elapsed >= (index == 1 and 0 or Trail.MIN_SEGMENT_SECONDS)
end
function Trail.advance(index)
    if index == #Trail.points then return nil, true end
    return index + 1, false
end
return Trail

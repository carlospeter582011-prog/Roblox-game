-- Server-authoritative chase skill bonus. The client never submits distance or bonus.
-- Close catches reward deliberately approaching a moving cloud, without blocking beginners.
local Finesse = {}
Finesse.MAX_BONUS_XP = 8
function Finesse.bonus(distance, catchRadius)
    if type(distance) ~= "number" or type(catchRadius) ~= "number"
        or distance ~= distance or catchRadius ~= catchRadius
        or distance < 0 or distance == math.huge
        or catchRadius <= 0 or catchRadius == math.huge then
        return 0
    end
    local ratio = distance / catchRadius
    if ratio <= 0.3 then return 8 end
    if ratio <= 0.6 then return 4 end
    return 0
end
return Finesse

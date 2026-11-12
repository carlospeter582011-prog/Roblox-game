-- Pure companion training economy rules. Server controls ownership, funds and cooldown.
local Rules = {}
Rules.COOLDOWN = 180
Rules.MAX_BOND = 1000000
function Rules.quote(points)
    if type(points) ~= "number" or points ~= points or points == math.huge or points < 0 or points ~= math.floor(points) or points > Rules.MAX_BOND then return nil end
    if points >= 100 then return nil end
    if points >= 40 then return 160, 15 end
    if points >= 10 then return 90, 10 end
    return 45, 5
end
function Rules.purchase(coins, points, now, lastTime)
    if type(coins) ~= "number" or coins ~= coins or coins == math.huge or coins < 0 or coins ~= math.floor(coins) then return nil, "Invalid balance" end
    if type(now) ~= "number" or now ~= now or now == math.huge or now < 0 then return nil, "Invalid time" end
    if lastTime ~= nil and (type(lastTime) ~= "number" or lastTime ~= lastTime or lastTime == math.huge or lastTime > now) then return nil, "Invalid cooldown" end
    if lastTime and now - lastTime < Rules.COOLDOWN then return nil, "Training recharging" end
    local cost, gain = Rules.quote(points)
    if not cost then return nil, "Companion fully trained" end
    if coins < cost then return nil, "Not enough Coins" end
    return { coins = coins - cost, points = math.min(Rules.MAX_BOND, points + gain), cost = cost, gain = gain }
end
return Rules

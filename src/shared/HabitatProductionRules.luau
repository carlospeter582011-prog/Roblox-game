-- Server-side habitat production rules. Pure Luau, no Roblox globals.
-- One meadow habitat per player, production is capped at 12 hours offline.
local Rules = {}
Rules.PRICE = 240
Rules.UNLOCK_CATCHES = 12
Rules.INTERVAL = 300
Rules.COINS_PER_INTERVAL = 15
Rules.MAX_INTERVALS = 144
local function integer(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge and n >= 0 and n == math.floor(n)
end
function Rules.canBuy(data)
    if type(data) ~= "table" then return false, "profile" end
    if data.habitatOwned == true then return false, "owned" end
    if not integer(data.captures) or data.captures < Rules.UNLOCK_CATCHES then return false, "locked" end
    if not integer(data.coins) or data.coins < Rules.PRICE then return false, "coins" end
    return true
end
function Rules.buy(data, now)
    if not integer(now) or now < 1 then return false, "time" end
    local ok, why = Rules.canBuy(data)
    if not ok then return false, why end
    data.coins -= Rules.PRICE
    data.habitatOwned = true
    data.habitatLastClaim = now
    return true
end
function Rules.pending(data, now)
    if type(data) ~= "table" or data.habitatOwned ~= true or not integer(now) then return 0 end
    local last = data.habitatLastClaim
    if not integer(last) or last < 1 or now <= last then return 0 end
    return math.min(Rules.MAX_INTERVALS, math.floor((now - last) / Rules.INTERVAL))
end
function Rules.claim(data, now)
    local count = Rules.pending(data, now)
    if count == 0 or not integer(data.coins) or data.coins > 1e12 - count * Rules.COINS_PER_INTERVAL then
        return false, 0
    end
    data.coins += count * Rules.COINS_PER_INTERVAL
    -- Discard overflow beyond cap, preventing perpetual backlog farming.
    data.habitatLastClaim = (now - data.habitatLastClaim > Rules.MAX_INTERVALS * Rules.INTERVAL)
        and now or data.habitatLastClaim + count * Rules.INTERVAL
    return true, count * Rules.COINS_PER_INTERVAL
end
return Rules

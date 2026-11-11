-- Pure server-side rules for a repeatable companion bond training Coin sink.
local Rules = {}
Rules.COST = 75
Rules.GAIN = 5
Rules.COOLDOWN = 45
Rules.MAX_COINS = 1000000000
function Rules.propose(coins, bond, owned, now, last)
    if not owned then return nil, "companion_not_owned" end
    for _, n in ipairs({coins, bond, now}) do
        if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge or n < 0 then
            return nil, "invalid_state"
        end
    end
    if coins ~= math.floor(coins) or coins > Rules.MAX_COINS
        or bond ~= math.floor(bond) or bond > 1000000 then return nil, "invalid_state" end
    if type(last) == "number" and last == last and last >= 0 then
        if now < last or now - last < Rules.COOLDOWN then return nil, "cooldown" end
    end
    if coins < Rules.COST then return nil, "insufficient_coins" end
    if bond >= 1000000 then return nil, "max_bond" end
    return { coins = coins - Rules.COST, bond = math.min(1000000, bond + Rules.GAIN), at = now }
end
return Rules

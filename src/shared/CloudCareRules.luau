-- Server-side care contract: coins are a sink, bond is bounded and earned.
local Rules = {}
Rules.COST = 45
Rules.BOND_GAIN = 5
Rules.COOLDOWN = 300
function Rules.evaluate(coins, bond, owns, elapsed)
    if owns ~= true then return false, "Equip an owned cloud" end
    if type(coins) ~= "number" or coins ~= coins or coins < Rules.COST or coins == math.huge then return false, "Need 45 Coins" end
    if type(bond) ~= "number" or bond ~= bond or bond < 0 or bond == math.huge then return false, "Invalid bond" end
    if bond >= 1000000 then return false, "Bond maxed" end
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < Rules.COOLDOWN then return false, "Care station recharging" end
    return true, math.min(1000000, math.floor(bond) + Rules.BOND_GAIN)
end
return Rules

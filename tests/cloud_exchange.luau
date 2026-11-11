local Rules = require("../src/shared/CloudExchangeRules")
local catalog = { breeze = { baseRewardCoins = 20 }, rare = { baseRewardCoins = 1000 } }
local function eq(a,b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end
assert(Rules.quote("breeze", { breeze = 2 }, catalog) == nil)
assert(Rules.quote("unknown", { unknown = 9 }, catalog) == nil)
assert(Rules.quote("breeze", { breeze = math.huge }, catalog) == nil)
local qty, coins, xp = Rules.quote("breeze", { breeze = 3 }, catalog)
eq(qty, 2) eq(coins, 40) eq(xp, 10)
local _, cappedCoins, cappedXp = Rules.quote("rare", { rare = 8 }, catalog)
eq(cappedCoins, 500) eq(cappedXp, 100)
print("Cloud exchange pure regression tests passed")

return true

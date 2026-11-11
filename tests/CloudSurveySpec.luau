local Rules = require("../src/shared/CloudSurveyRules")
local catalog = {}
local owned = {}
for i = 1, 15 do catalog["s" .. i] = {}; owned["s" .. i] = 1 end
assert(Rules.uniqueOwned(owned, catalog) == 15)
owned.unknown = 999
owned.s1 = math.huge
assert(Rules.uniqueOwned(owned, catalog) == 14)
owned.s1 = 1
local r = Rules.evaluate(1, owned, catalog, 1000, 0, 10, 20)
assert(r and r.coins == 50 and r.xp == 45)
assert(Rules.evaluate(1, owned, catalog, 1001, 1000, 10, 20) == nil)
assert(Rules.evaluate(4, owned, catalog, 1000, 0, 10, 20) == nil)
assert(Rules.evaluate(1, {}, catalog, 1000, 0, 10, 20) == nil)
assert(Rules.evaluate(1, owned, catalog, 1000, 0, math.huge, 20) == nil)
print("Cloud Survey rules: passed")

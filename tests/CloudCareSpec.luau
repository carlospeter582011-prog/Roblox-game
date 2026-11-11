local Rules = require("../src/shared/CloudCareRules")
assert(Rules.evaluate(45, 0, true, 300) == true)
local ok, points = Rules.evaluate(45, 39, true, 300)
assert(ok and points == 44)
assert(Rules.evaluate(44, 0, true, 300) == false)
assert(Rules.evaluate(45, 0, false, 300) == false)
assert(Rules.evaluate(45, 0, true, 299) == false)
assert(Rules.evaluate(45, 1000000, true, 300) == false)
return true

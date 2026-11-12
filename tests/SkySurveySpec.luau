local Rules = require("../src/shared/SkySurveyRules")
assert(#Rules.STATIONS == 3)
assert(Rules.check(1, "meadow", 5, 0, 0))
assert(Rules.check(2, "eastwind", 14, 90, 0))
local ok, reason = Rules.check(3, "ridge", 8, 170, 0)
assert(ok and reason == "complete")
for _, case in ipairs({
    { 1, "ridge", 2, 0, 0 },
    { 2, "eastwind", 15, 1, 0 },
    { 3, "ridge", 3, 181, 0 },
    { 1, "meadow", 2, 0, 100 },
    { 1, "meadow", 0/0, 0, 0 },
    { 1, "meadow", 1, math.huge, 0 },
    { 4, "meadow", 1, 0, 0 },
}) do
    assert(not Rules.check(table.unpack(case)))
end
assert(Rules.cooldownActive({ expires = 500 }, 499))
assert(not Rules.cooldownActive({ expires = 500 }, 500))
assert(not Rules.cooldownActive({ expires = math.huge }, 499))
assert(not Rules.cooldownActive({ expires = 0/0 }, 499))
assert(not Rules.cooldownActive("bad", 499))
return true

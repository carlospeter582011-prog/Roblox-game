local Rules = require("../src/shared/SkyWellRules")
assert(Rules.canUse(10, 40, 100, 90, true), "injured player in range can heal")
assert(Rules.healedHealth(40, 100) == 75, "35 percent max health restored")
assert(Rules.healedHealth(90, 100) == 100, "health capped at maximum")
assert(not Rules.canUse(15, 40, 100, 90, true), "distance checked on server")
assert(not Rules.canUse(10, 0, 100, 90, true), "dead players rejected")
assert(not Rules.canUse(10, 100, 100, 90, true), "full health cannot consume cooldown")
assert(not Rules.canUse(10, 40, 100, 89, true), "cooldown enforced")
assert(not Rules.canUse(10, 40, 100, 90, false), "profile readiness required")
assert(not Rules.canUse(0/0, 40, 100, 90, true), "NaN rejected")
assert(not Rules.canUse(10, 40, math.huge, 90, true), "infinity rejected")
print("SkyWellSpec passed")

return true

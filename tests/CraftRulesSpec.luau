-- Crafting rules run without Roblox services.
local Craft = require("../src/shared/CraftRules")
local Tools = require("../src/shared/CatchToolCatalog")
local function check(ok, message) if not ok then error(message, 2) end end
local function profile()
    return { captures = 20, coins = 100, ownedTools = { starter_net = true },
        species = { breeze = 4, cirrus = 2, drizzle = 4, mist = 3, pebble = 5, gale = 3 } }
end
local a = profile()
check(Craft.apply(a, "wind_lasso", Tools), "valid craft rejected")
check(a.coins == 75 and a.species.breeze == 1 and a.species.cirrus == 1, "deduction incorrect")
check(a.ownedTools.wind_lasso == true, "ownership not granted")
check(not Craft.apply(a, "wind_lasso", Tools), "duplicate craft allowed")
check(a.coins == 75, "duplicate charged coins")
local b = profile()
b.species.breeze = 3
check(not Craft.apply(b, "wind_lasso", Tools), "last copy consumed")
check(b.coins == 100, "failed craft mutated coins")
check(not Craft.apply(profile(), "archon_net", Tools), "unknown recipe allowed")
local c = profile()
c.captures = 1
check(not Craft.apply(c, "mist_gloves", Tools), "unlock bypassed")
local d = profile()
d.coins = 0/0
check(not Craft.apply(d, "wind_lasso", Tools), "NaN accepted")
return true

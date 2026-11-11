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

-- Every recipe must be independently craftable and spend only its listed inputs.
for _, id in ipairs({ "wind_lasso", "mist_gloves", "cloud_magnet" }) do
    local sample = profile()
    local recipe = Craft.Recipes[id]
    local originalCoins = sample.coins
    local before = {}
    for speciesId in pairs(sample.species) do before[speciesId] = sample.species[speciesId] end
    check(Craft.apply(sample, id, Tools), "recipe failed: " .. id)
    check(sample.ownedTools[id] == true, "tool not granted: " .. id)
    check(sample.coins == originalCoins - recipe.coins, "incorrect coin debit: " .. id)
    for speciesId, count in pairs(before) do
        check(sample.species[speciesId] == count - (recipe.species[speciesId] or 0),
            "unexpected species debit: " .. id .. "/" .. speciesId)
    end
end
-- Missing one ingredient must never partially charge coins or consume other species.
local partial = profile()
partial.species.gale = 2
check(not Craft.apply(partial, "cloud_magnet", Tools), "missing ingredient accepted")
check(partial.coins == 100 and partial.species.pebble == 5 and partial.species.gale == 2,
    "failed recipe caused partial debit")
return true

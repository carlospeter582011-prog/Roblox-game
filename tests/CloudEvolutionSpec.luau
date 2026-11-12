local Rules = require("../src/shared/CloudEvolutionRules")
local Catalog = require("../src/shared/CloudCatalog")
local function eq(a,b) assert(a==b, tostring(a).." != "..tostring(b)) end
local function profile()
    return { coins = 400, species = { breeze = 2, drizzle = 2, thunder = 2 }, companionBond = { breeze = 10, drizzle = 10, thunder = 40 } }
end
local data = profile()
local ok, result = Rules.apply(data, Rules.Recipes[1], Catalog)
eq(ok,true) eq(result,"gale") eq(data.species.breeze,1) eq(data.species.gale,1) eq(data.coins,280)
local before = data.coins
eq(Rules.apply(data, Rules.Recipes[1], Catalog),false)
eq(data.coins,before) eq(data.species.breeze,1)
local invalid = profile()
invalid.coins = 0/0
eq(Rules.apply(invalid, Rules.Recipes[1], Catalog),false)
eq(invalid.species.breeze,2)
local unbonded = profile()
unbonded.companionBond.thunder = 39
eq(Rules.apply(unbonded, Rules.Recipes[3], Catalog),false)
eq(unbonded.coins,400)
local forged = { id = "fake", source = "breeze", result = "gale", copies = 0, bond = 0, coins = 0 }
eq(Rules.apply(profile(), forged, Catalog),false)
print("CloudEvolutionSpec: 5 assertions passed")

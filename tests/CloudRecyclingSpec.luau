local Rules = require("../src/shared/CloudRecyclingRules")
local catalog = { breeze = {}, drizzle = {} }
local function eq(a,b) assert(a==b, tostring(a).." ~= "..tostring(b)) end
eq(Rules.choose({ breeze=3 },catalog),nil)
eq(Rules.choose({ breeze=4,drizzle=7 },catalog),"breeze")
eq(Rules.choose({ ["breeze:golden"]=9 },catalog),nil)
local p = { species={breeze=7},coins=10,xp=0 }
local ok,id = Rules.apply(p,catalog)
eq(ok,true) eq(id,"breeze") eq(p.species.breeze,4) eq(p.coins,45) eq(p.xp,20)
eq(Rules.apply({species={breeze=3},coins=10,xp=0},catalog),false)
eq(Rules.apply({species={breeze=5},coins=math.huge,xp=0},catalog),false)
eq(Rules.apply({species={breeze=5},coins=0,xp=0/0},catalog),false)
return true

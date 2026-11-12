local Rules = require("../src/shared/SkyNavigationRules")
local function eq(a,b) assert(a==b, tostring(a).." ~= "..tostring(b)) end
local p = 0
for i,d in ipairs({"north","east","south","west"}) do
    local done
    p,done = Rules.step(p,d,10)
    eq(p,i)
    eq(done,i==4)
end
eq(select(1,Rules.step(2,"west",10)),0)
eq(select(1,Rules.step(2,"south",46)),0)
eq(select(1,Rules.step(2,"south",0/0)),0)
eq(select(1,Rules.step(-1,"north",1)),0)
print("SkyNavigationRulesSpec passed")

local Rules = require("../src/shared/ObservatoryRules")
local function eq(a,b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end
eq(Rules.canScan(100, nil), true)
eq(Rules.canScan(129, 100), false)
eq(Rules.canScan(130, 100), true)
eq(Rules.canScan(99, 100), false)
local origin = {x=0,z=0}
local list = {{id="b",species="breeze",x=10,z=0},{id="a",species="mist",x=10,z=0},
{id="far",species="storm",x=181,z=0},{id="bad",species="mist",x=math.huge,z=0}}
local nearest, distance = Rules.nearest(origin,list)
eq(nearest.id,"a")
eq(distance,10)
eq(Rules.nearest(origin,{{id="far",species="storm",x=181,z=0}}),nil)
print("ObservatorySpec passed")

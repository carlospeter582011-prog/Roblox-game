local Rules = require("../src/shared/SkyBeaconRules")
local function eq(a,b) assert(a==b, tostring(a).." != "..tostring(b)) end
local stage,status=Rules.advance(0,1,0,5);eq(stage,1);eq(status,"progress")
stage,status=Rules.advance(stage,2,12,5);eq(stage,2)
stage,status=Rules.advance(stage,3,22,5);eq(stage,0);eq(status,"complete")
stage,status=Rules.advance(1,3,5,5);eq(stage,0);eq(status,"wrong")
stage,status=Rules.advance(2,3,36,5);eq(stage,0);eq(status,"expired")
stage,status=Rules.advance(1,2,2,99);eq(stage,1);eq(status,"far")
stage,status=Rules.advance(1,2,2,0/0);eq(stage,1);eq(status,"far")
return true

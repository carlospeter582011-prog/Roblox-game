local Rules = require("../src/shared/SkySprintRules")
local function eq(a,b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end
local state = {started=10,next=1}
eq(select(1,Rules.advance(state,2,11,1)),false)
eq(state.next,1)
for i=1,5 do
    local ok, status = Rules.advance(state,i,10+i,5)
    eq(ok,true)
    eq(status,i==5 and "finished" or "progress")
end
eq(select(1,Rules.advance({started=10,next=1},1,131,5)),false)
eq(select(1,Rules.advance({started=10,next=1},1,11,math.huge)),false)
eq(select(1,Rules.advance({started=10,next=1},1,11,0/0)),false)
eq(select(1,Rules.advance({started=10,next=1},1,11,-1)),false)
eq(select(1,Rules.advance({started=10,next=1},1,11,14)),false)
print("SkySprintRules: 11 assertions passed")

return true

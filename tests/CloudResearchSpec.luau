return function(test, eq)
local Rules = require("../src/shared/CloudResearchRules")
test("research upgrade purchases are capped and charge exact costs", function()
local p = { coins = 2000, captures = 100, researchLevel = 0 }
for i = 1, 3 do
    local old = p.coins
    local ok = Rules.purchase(p)
    eq(ok,true)
    eq(p.researchLevel,i)
    eq(p.coins,old - Rules.COSTS[i])
end
eq(Rules.purchase(p),false)
eq(Rules.bonusXp(100,3),30)
eq(Rules.bonusXp(100,math.huge),0)
eq(Rules.bonusXp(0/0,3),0)
end)
test("research unlock and insufficient funds are enforced", function()
local q = { coins = 200, captures = 9, researchLevel = 0 }
eq(Rules.purchase(q),false)
eq(q.coins,200)
q.captures = 10
eq(Rules.purchase(q),true)
eq(q.coins,50)

end)
end

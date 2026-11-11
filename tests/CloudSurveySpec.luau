return function(test, eq)
test("survey unique species ignores unknown and invalid counts", function()
    local Rules = require("../src/shared/CloudSurveyRules")
    local catalog, owned = {}, {}
    for i = 1, 15 do catalog["s" .. i] = {}; owned["s" .. i] = 1 end
    eq(Rules.uniqueOwned(owned, catalog), 15, "15 discovered")
    owned.unknown = 999
    owned.s1 = math.huge
    eq(Rules.uniqueOwned(owned, catalog), 14, "invalid ignored")
end)
test("survey rewards respect progression, cooldown and caps", function()
    local Rules = require("../src/shared/CloudSurveyRules")
    local catalog, owned = {}, {}
    for i = 1, 15 do catalog["s" .. i] = {}; owned["s" .. i] = 1 end
    local r = Rules.evaluate(1, owned, catalog, 1000, 0, 10, 20)
    eq(r.coins, 50, "coins")
    eq(r.xp, 45, "xp")
    eq(Rules.evaluate(1, owned, catalog, 1001, 1000, 10, 20), nil, "cooldown")
    eq(Rules.evaluate(4, owned, catalog, 1000, 0, 10, 20), nil, "invalid tier")
    eq(Rules.evaluate(1, {}, catalog, 1000, 0, 10, 20), nil, "missing species")
    eq(Rules.evaluate(1, owned, catalog, 1000, 0, math.huge, 20), nil, "invalid wallet")
end)
end

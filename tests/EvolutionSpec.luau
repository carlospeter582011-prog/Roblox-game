-- Regression tests for EvolutionRules. Pure Luau, no Roblox.
return function(test, eq)
    local Rules = require("../src/shared/EvolutionRules")

    test("breeze evolves to gale at 25 catches", function()
        local can, evolved = Rules.canEvolve("breeze", 25)
        eq(can, true, "can evolve")
        eq(evolved, "gale", "evolved id")
        eq(Rules.canEvolve("breeze", 24), false, "below threshold")
    end)

    test("unknown species never evolves", function()
        eq(Rules.canEvolve("nonexistent", 1000), false, "no path")
        eq(Rules.evolvedIdFor("nonexistent"), nil, "no evolved")
    end)

    test("required counts match catalog paths", function()
        eq(Rules.requiredFor("ember"), 12, "ember threshold")
        eq(Rules.requiredFor("pebble"), 35, "pebble threshold")
        eq(Rules.evolvedIdFor("sunbeam"), "solar", "sunbeam path")
    end)

    test("invalid count never evolves", function()
        eq(Rules.canEvolve("frost", -1), false, "negative")
        eq(Rules.canEvolve("frost", 0/0), false, "nan")
    end)
end

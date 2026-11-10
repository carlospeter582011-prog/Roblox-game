return function(test, eq)
    local Rules = require("../src/shared/BossElementObjectives")
    local catalog = {
        breeze = {element="Air"}, drizzle={element="Water"},
        spark={element="Fire"}, thunder={element="Storm"},
        sunbeam={element="Light"}, pebble={element="Earth"}
    }
    test("boss elemental objectives only count eligible server species", function()
        local initial = Rules.snapshot({breeze=2, drizzle=1, spark=1, thunder=0}, catalog)
        local current = {breeze=4, drizzle=2, spark=3, thunder=2, sunbeam=1, pebble=20}
        eq(Rules.progress("meadow", initial, current, catalog, 10), 3, "meadow air/water")
        eq(Rules.progress("eastwind", initial, current, catalog, 10), 3, "eastwind air/light")
        eq(Rules.progress("ridge", initial, current, catalog, 10), 4, "ridge storm/fire")
        eq(Rules.progress("unknown", initial, current, catalog, 10), 0, "unknown boss")
    end)
    test("boss elemental objectives resist invalid counts and variant double-credit", function()
        local initial = Rules.snapshot({breeze=5, thunder=2, ["breeze:golden"]=100}, catalog)
        local current = {breeze=3, thunder=math.huge, ["breeze:golden"]=999, spark=1}
        eq(Rules.progress("meadow", initial, current, catalog, 3), 0, "decrements and variants ignored")
        eq(Rules.progress("ridge", initial, current, catalog, 3), 1, "invalid counts ignored")
        eq(Rules.progress("ridge", initial, current, catalog, 0), 0, "invalid goal")
        eq(Rules.progress("meadow", {}, {breeze=999}, catalog, 3), 3, "capped goal")
        eq(Rules.label("ridge"), "Storm/Fire", "player guidance")
    end)
end

return function(test, eq)
    local Mutations = require("../src/shared/Mutations")

    test("mutation roll can return nil", function()
        local fixed = function() return 0.99 end
        eq(Mutations.roll(fixed), nil)
    end)

    test("mutation key prefixes correctly", function()
        eq(Mutations.key("breeze", nil), "breeze")
        eq(Mutations.key("breeze", "golden"), "breeze:golden")
    end)

    test("bonus coins applies multiplier", function()
        eq(Mutations.bonusCoins(10, "golden"), 30)
        eq(Mutations.bonusCoins(10, nil), 10)
    end)

    test("roll is deterministic with fixed rng", function()
        local calls = 0
        local function rng()
            calls += 1
            return calls == 1 and 0.01 or 0.1
        end
        local id = Mutations.roll(rng)
        eq(type(id), "string")
    end)
end

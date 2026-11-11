return function(test, eq)
    local Rules = require("../src/shared/IslandPlacementRules")
    test("island building spends coins and rejects overlapping structures", function()
        local first = Rules.place({}, { id = "cloud_perch", x = 0, z = 0, rotation = 0 }, 500, 0)
        eq(first.remainingCoins, 420, "coin sink")
        eq(#first.items, 1, "placed")
        local second, reason = Rules.place(first.items, { id = "windmill", x = 1, z = 0, rotation = 1 }, 420, 50)
        eq(second, nil, "blocked overlap")
        eq(reason, "overlap", "reason")
        local distant = Rules.place(first.items, { id = "windmill", x = 12, z = 0, rotation = 1 }, 420, 50)
        eq(#distant.items, 2, "distant placement")
        eq(distant.remainingCoins, 170, "cost")
    end)
    test("island building enforces unlocks, capacity, coordinates and item whitelist", function()
        local _, locked = Rules.place({}, { id = "windmill", x = 0, z = 0, rotation = 0 }, 1000, 0)
        eq(locked, "locked", "catch gate")
        local _, poor = Rules.place({}, { id = "cloud_perch", x = 0, z = 0, rotation = 0 }, 0, 0)
        eq(poor, "insufficient_coins", "coin gate")
        eq(Rules.validate({ id = "bad", x = 0, z = 0, rotation = 0 }), false, "whitelist")
        eq(Rules.validate({ id = "cloud_perch", x = math.huge, z = 0, rotation = 0 }), false, "infinite")
        eq(Rules.validate({ id = "cloud_perch", x = 23, z = 0, rotation = 0 }), false, "boundary")
        eq(Rules.validate({ id = "cloud_perch", x = 0, z = 0, rotation = 4 }), false, "rotation")
    end)
    test("island layouts sanitize invalid and duplicate placements and survive saves", function()
        local Core = require("../src/server/ProfileCore")
        local layout = {
            { id = "cloud_perch", x = 0, z = 0, rotation = 0 },
            { id = "cloud_perch", x = 0, z = 0, rotation = 0 },
            { id = "windmill", x = 12, z = 0, rotation = 1 },
            { id = "forged", x = 20, z = 0, rotation = 0 },
        }
        local cleaned = Core.sanitize({ islandLayout = layout }, {}, 0)
        eq(#cleaned.islandLayout, 2, "only valid nonoverlapping placements")
        eq(cleaned.islandLayout[2].id, "windmill", "second item")
        eq(#Core.sanitize({ islandLayout = "bad" }, {}, 0).islandLayout, 0, "bad payload")
    end)
end

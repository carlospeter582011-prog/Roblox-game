local Rules = require("../src/shared/HabitatProductionRules")
local Core = require("../src/server/ProfileCore")
return function(test, eq)
    test("habitat requires real progression and Coins", function()
        local data = { captures = 11, coins = 500 }
        eq(Rules.buy(data, 1000), false, "locked")
        data.captures = 12
        data.coins = 239
        eq(Rules.buy(data, 1000), false, "insufficient Coins")
        data.coins = 500
        eq(Rules.buy(data, 1000), true, "purchase")
        eq(data.coins, 260, "spent exactly once")
        eq(Rules.buy(data, 1000), false, "cannot repurchase")
    end)
    test("habitat pays only elapsed intervals with offline cap and no duplicate claim", function()
        local data = { captures = 12, coins = 500 }
        Rules.buy(data, 1000)
        eq(Rules.claim(data, 1299), false, "not yet")
        eq(Rules.claim(data, 1300), true, "first interval")
        eq(data.coins, 275, "one payout")
        eq(Rules.claim(data, 1300), false, "duplicate prevented")
        eq(Rules.claim(data, 100000), true, "offline payout")
        eq(data.coins, 275 + 144 * 15, "12-hour cap")
        eq(Rules.claim(data, 100000), false, "offline duplicate")
    end)
    test("habitat rejects invalid time and persisted values", function()
        local data = { captures = 12, coins = 500 }
        eq(Rules.buy(data, math.huge), false, "invalid timestamp")
        eq(Rules.buy(data, 1000), true, "valid")
        eq(Rules.claim(data, 0/0), false, "nan time")
        local clean = Core.sanitize({ habitatOwned = true, habitatLastClaim = 1234.8 }, {}, 1000)
        eq(clean.habitatOwned, true, "owned persisted")
        eq(clean.habitatLastClaim, 1234, "timestamp floored")
        local invalid = Core.sanitize({ habitatOwned = "yes", habitatLastClaim = math.huge }, {}, 1000)
        eq(invalid.habitatOwned, false, "invalid ownership")
        eq(invalid.habitatLastClaim, 0, "invalid time")
    end)
end

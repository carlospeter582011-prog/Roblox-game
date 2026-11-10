return function(test, eq)
    local Mastery = require("../src/shared/SpeciesMastery")
    test("species mastery awards exactly at milestones", function()
        for i, m in ipairs(Mastery.MILESTONES) do
            local coins, xp, tier = Mastery.reward(m.catches - 1, m.catches)
            eq(coins, m.coins, "coins " .. i)
            eq(xp, m.xp, "xp " .. i)
            eq(tier, i, "tier " .. i)
            eq(Mastery.level(m.catches), i, "level " .. i)
        end
    end)
    test("species mastery cannot be farmed with repeated or skipped counts", function()
        eq(select(1, Mastery.reward(5, 6)), 0, "post milestone")
        eq(select(1, Mastery.reward(4, 4)), 0, "duplicate")
        eq(select(1, Mastery.reward(4, 15)), 0, "skip")
        eq(select(1, Mastery.reward(-1, 5)), 0, "negative")
        eq(select(1, Mastery.reward(math.huge, math.huge)), 0, "infinite")
        eq(select(1, Mastery.reward(30, 31)), 0, "capped")
    end)
    test("species mastery uses independent species counters across rejoin", function()
        local counts = { breeze = 4, drizzle = 14 }
        local function catch(id)
            local before = counts[id]
            counts[id] = before + 1
            return Mastery.reward(before, counts[id])
        end
        eq(select(1, catch("breeze")), 40, "breeze tier one")
        eq(select(1, catch("drizzle")), 120, "drizzle tier two")
        eq(select(1, catch("breeze")), 0, "breeze no duplicate")
        eq(Mastery.level(counts.drizzle), 2, "rejoin-derived tier")
    end)
end

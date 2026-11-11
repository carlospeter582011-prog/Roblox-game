return function(test, eq)
    local Catalog = require("../src/shared/WorldCatalog")
    local Rules = require("../src/shared/OuterWorldRules")
    test("outer world destinations match seven distinct catalog entries", function()
        local entries = Rules.entries(Catalog)
        eq(#entries, 7, "seven outer regions")
        for i, entry in ipairs(entries) do
            eq(entry.order, i + 3, "world order")
            eq(entry.requiredCatches, Catalog[entry.id].unlockCatches, "catalog threshold")
            if i > 1 then
                eq(entry.x - entries[i - 1].x, 180, "separated islands")
            end
        end
    end)
    test("outer world portals reject locked, invalid and remote interactions", function()
        local id = "lost_cloud_kingdom"
        eq(Rules.canActivate(id, 599, 2, true, Catalog), false, "locked")
        eq(Rules.canActivate(id, 600, 15, true, Catalog), true, "unlocked")
        eq(Rules.canActivate(id, 600, 15.01, true, Catalog), false, "out of range")
        eq(Rules.canActivate(id, 600, 2, false, Catalog), false, "dead")
        eq(Rules.canActivate(id, math.huge, 2, true, Catalog), false, "infinite catches")
        eq(Rules.canActivate(id, 600, 0 / 0, true, Catalog), false, "NaN distance")
        eq(Rules.canActivate("fake", 999, 2, true, Catalog), false, "unknown")
        eq(Rules.canActivate("sky_meadow", 999, 2, true, Catalog), false, "not an outer destination")
    end)
end

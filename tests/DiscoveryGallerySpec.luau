return function(test, eq)
    local Gallery = require("../src/shared/DiscoveryGalleryRules")
    local catalog = {
        breeze = { rarity = "Common", name = "Breeze" },
        mist = { rarity = "Common", name = "Mist" },
        aurora = { rarity = "Epic", name = "Aurora" },
    }
    test("gallery tracks only distinct discovered species in each tier", function()
        local found, total, missing = Gallery.summary(catalog, { breeze = 50, mist = 0, aurora = 2 }, "Common")
        eq(found, 1, "one discovered")
        eq(total, 2, "two common species")
        eq(missing, "mist", "missing hint")
        eq(Gallery.completed(catalog, { breeze = 50 }, "Common"), false, "not complete")
    end)
    test("gallery does not count mutation keys or invalid saved counts", function()
        local found, total = Gallery.summary(catalog, { ["breeze:golden"] = 3, breeze = "7", mist = -4 }, "Common")
        eq(found, 0, "no valid discoveries")
        eq(total, 2, "catalog total")
        eq(Gallery.completed(catalog, { breeze = 1, mist = 1 }, "Common"), true, "completed")
        eq(Gallery.completed(catalog, {}, "Secret"), false, "empty tier is not complete")
    end)
end

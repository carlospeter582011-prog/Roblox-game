-- Unit tests for pure EvolutionRules.
local Catalog = require("../src/shared/CloudCatalog")
local Rules = require("../src/shared/EvolutionRules")

return function(test, eq)
    test("evolution threshold scales by rarity", function()
        eq(Rules.thresholdFor("Common"), 5, "common")
        eq(Rules.thresholdFor("Uncommon"), 8, "uncommon")
        eq(Rules.thresholdFor("Rare"), 12, "rare")
        eq(Rules.thresholdFor("Epic"), 20, "epic")
        eq(Rules.thresholdFor("Mythic"), 999, "mythic no evolve")
    end)

    test("canEvolve requires enough owned of known species", function()
        eq(Rules.canEvolve("breeze", 5, Catalog), true, "ready")
        eq(Rules.canEvolve("breeze", 4, Catalog), false, "short")
        eq(Rules.canEvolve("unknown", 10, Catalog), false, "unknown")
        eq(Rules.canEvolve("breeze", -1, Catalog), false, "negative")
    end)

    test("nextEvolution finds same-element higher rarity deterministically", function()
        local nextId = Rules.nextEvolution("breeze", Catalog)
        eq(type(nextId), "string", "found")
        local nextEntry = Catalog[nextId]
        eq(nextEntry.element, "Air", "same element")
        eq(nextEntry.rarity, "Uncommon", "next rarity")
    end)

    test("evolve returns next species when ready", function()
        local result, reason = Rules.evolve("breeze", 5, Catalog)
        eq(reason, "ok", "success")
        eq(type(result), "string", "species id")
        local fail, why = Rules.evolve("breeze", 3, Catalog)
        eq(fail, nil, "not ready")
        eq(why, "not ready", "reason")
    end)

    test("fusionPreview requires same element different species", function()
        local preview = Rules.fusionPreview("breeze", "cirrus", Catalog)
        eq(type(preview), "string", "preview")
        eq(Rules.fusionPreview("breeze", "breeze", Catalog), nil, "same id")
        eq(Rules.fusionPreview("breeze", "drizzle", Catalog), nil, "different element")
    end)
end

-- Pure evolution recipes. No Roblox globals.
-- Consume N of fromSpecies to gain 1 of toSpecies. Both must exist in CloudCatalog.
local Catalog = {
    breeze_to_gale = {
        id = "breeze_to_gale",
        fromSpecies = "breeze",
        required = 5,
        toSpecies = "gale",
        name = "Evolve Breeze to Gale",
    },
    drizzle_to_mist = {
        id = "drizzle_to_mist",
        fromSpecies = "drizzle",
        required = 4,
        toSpecies = "mist",
        name = "Evolve Drizzle to Mist",
    },
    pebble_to_crystal = {
        id = "pebble_to_crystal",
        fromSpecies = "pebble",
        required = 6,
        toSpecies = "crystal",
        name = "Evolve Pebble to Crystal",
    },
    spark_to_ember = {
        id = "spark_to_ember",
        fromSpecies = "spark",
        required = 5,
        toSpecies = "ember",
        name = "Evolve Spark to Ember",
    },
    frost_to_glacier = {
        id = "frost_to_glacier",
        fromSpecies = "frost",
        required = 4,
        toSpecies = "glacier",
        name = "Evolve Frost to Glacier",
    },
}
return table.freeze(Catalog)

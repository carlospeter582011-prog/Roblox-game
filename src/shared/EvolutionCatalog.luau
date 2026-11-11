-- Catch a Cloud: evolution paths. Each entry defines a source species that can evolve into a target.
-- Requirements are pure numbers so this module stays free of Roblox types.
-- evolutionCostCoins: coin sink paid on successful evolution.
-- minCatches: minimum owned count of the source species required (must consume 1).
-- minBond: optional minimum companion bond points if the source is the equipped companion (0 = ignore).
local Catalog = {
    breeze_to_gale = {
        id = "breeze_to_gale",
        sourceId = "breeze",
        targetId = "gale",
        evolutionCostCoins = 150,
        minCatches = 3,
        minBond = 0,
    },
    drizzle_to_mist = {
        id = "drizzle_to_mist",
        sourceId = "drizzle",
        targetId = "mist",
        evolutionCostCoins = 120,
        minCatches = 2,
        minBond = 0,
    },
    mist_to_mistveil = {
        id = "mist_to_mistveil",
        sourceId = "mist",
        targetId = "mistveil",
        evolutionCostCoins = 400,
        minCatches = 4,
        minBond = 10,
    },
    pebble_to_pebbleflow = {
        id = "pebble_to_pebbleflow",
        sourceId = "pebble",
        targetId = "pebbleflow",
        evolutionCostCoins = 180,
        minCatches = 3,
        minBond = 0,
    },
    spring_to_blossom = {
        id = "spring_to_blossom",
        sourceId = "spring",
        targetId = "blossom",
        evolutionCostCoins = 200,
        minCatches = 3,
        minBond = 5,
    },
}
return table.freeze(Catalog)

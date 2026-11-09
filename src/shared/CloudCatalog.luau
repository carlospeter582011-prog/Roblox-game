-- Catch a Cloud: initial data-driven species catalog. Expand without changing IDs.
local Catalog = {
    breeze = {
        id = "breeze",
        name = "Breeze Cloud",
        rarity = "Common",
        baseCatchRadius = 12,
        baseRewardCoins = 10,
        element = "Air",
    },
    drizzle = {
        id = "drizzle",
        name = "Drizzle Cloud",
        rarity = "Common",
        baseCatchRadius = 10,
        baseRewardCoins = 12,
        element = "Water",
    },
}
return table.freeze(Catalog)

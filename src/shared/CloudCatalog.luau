-- Catch a Cloud: data-driven species catalog. Expand without changing IDs.
-- spawnWeight: relative chance among spawnable species (see SpawnRules).
-- colorRGB: 0-255 body tint, kept as plain numbers so this module stays free of Roblox types.
local Catalog = {
    breeze = {
        id = "breeze",
        name = "Breeze Cloud",
        rarity = "Common",
        baseCatchRadius = 12,
        baseRewardCoins = 10,
        element = "Air",
        spawnWeight = 70,
        colorRGB = { 211, 238, 255 },
    },
    drizzle = {
        id = "drizzle",
        name = "Drizzle Cloud",
        rarity = "Common",
        baseCatchRadius = 10,
        baseRewardCoins = 12,
        element = "Water",
        spawnWeight = 30,
        colorRGB = { 158, 196, 235 },
    },
}
return table.freeze(Catalog)

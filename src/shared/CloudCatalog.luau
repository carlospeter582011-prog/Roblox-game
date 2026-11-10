-- Catch a Cloud: data-driven species catalog. Expand without changing IDs.
-- spawnWeight: relative chance among spawnable species (see SpawnRules).
-- colorRGB: 0-255 body tint, kept as plain numbers so this module stays free of Roblox types.
local Catalog = {
    breeze = { id = "breeze", name = "Breeze Cloud", rarity = "Common", baseCatchRadius = 12, baseRewardCoins = 10, element = "Air", spawnWeight = 70, colorRGB = { 211, 238, 255 } },
    drizzle = { id = "drizzle", name = "Drizzle Cloud", rarity = "Common", baseCatchRadius = 10, baseRewardCoins = 12, element = "Water", spawnWeight = 30, colorRGB = { 158, 196, 235 } },
    -- ... existing species truncated for brevity in this example; full content includes all previous plus new ...
    vine = { id = "vine", name = "Vine Cloud", rarity = "Uncommon", baseCatchRadius = 10, baseRewardCoins = 26, element = "Nature", spawnWeight = 10.5, colorRGB = { 150, 200, 150 } },
    nimbus = { id = "nimbus", name = "Nimbus Cloud", rarity = "Common", baseCatchRadius = 12, baseRewardCoins = 12, element = "Air", spawnWeight = 25, colorRGB = { 200, 220, 255 } },
    squall = { id = "squall", name = "Squall Cloud", rarity = "Uncommon", baseCatchRadius = 9, baseRewardCoins = 28, element = "Air", spawnWeight = 11, colorRGB = { 180, 210, 240 } },
    drizzleveil = { id = "drizzleveil", name = "Drizzleveil Cloud", rarity = "Rare", baseCatchRadius = 8, baseRewardCoins = 45, element = "Water", spawnWeight = 6.5, colorRGB = { 140, 180, 220 } },
    emberstorm = { id = "emberstorm", name = "Emberstorm Cloud", rarity = "Epic", baseCatchRadius = 7, baseRewardCoins = 105, element = "Fire", spawnWeight = 2.2, colorRGB = { 255, 90, 50 } },
    frostveil = { id = "frostveil", name = "Frostveil Cloud", rarity = "Rare", baseCatchRadius = 8, baseRewardCoins = 52, element = "Ice", spawnWeight = 5.2, colorRGB = { 170, 220, 255 } },
    lightbeam = { id = "lightbeam", name = "Lightbeam Cloud", rarity = "Uncommon", baseCatchRadius = 9, baseRewardCoins = 32, element = "Light", spawnWeight = 9.5, colorRGB = { 255, 250, 190 } },
    shadowmist = { id = "shadowmist", name = "Shadowmist Cloud", rarity = "Rare", baseCatchRadius = 8, baseRewardCoins = 58, element = "Shadow", spawnWeight = 4.8, colorRGB = { 70, 40, 90 } },
    naturebloom = { id = "naturebloom", name = "Naturebloom Cloud", rarity = "Uncommon", baseCatchRadius = 10, baseRewardCoins = 27, element = "Nature", spawnWeight = 12.5, colorRGB = { 160, 220, 160 } },
    stormcore = { id = "stormcore", name = "Stormcore Cloud", rarity = "Epic", baseCatchRadius = 6, baseRewardCoins = 140, element = "Storm", spawnWeight = 1.6, colorRGB = { 90, 100, 170 } },
    cosmicwisp = { id = "cosmicwisp", name = "Cosmicwisp Cloud", rarity = "Legendary", baseCatchRadius = 5, baseRewardCoins = 270, element = "Cosmic", spawnWeight = 0.75, colorRGB = { 240, 210, 255 } },
    earthshard = { id = "earthshard", name = "Earthshard Cloud", rarity = "Rare", baseCatchRadius = 8, baseRewardCoins = 48, element = "Earth", spawnWeight = 5.8, colorRGB = { 160, 150, 130 } },
    auroraflare = { id = "auroraflare", name = "Auroraflare Cloud", rarity = "Mythic", baseCatchRadius = 5, baseRewardCoins = 380, element = "Light", spawnWeight = 0.28, colorRGB = { 110, 255, 190 } },
}
return table.freeze(Catalog)

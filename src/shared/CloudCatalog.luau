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
    cirrus = {
        id = "cirrus", name = "Cirrus Cloud", rarity = "Uncommon",
        baseCatchRadius = 9, baseRewardCoins = 18,
        element = "Air", spawnWeight = 22,
        colorRGB = { 235, 245, 255 },
    },
    mist = {
        id = "mist", name = "Mist Cloud", rarity = "Common",
        baseCatchRadius = 11, baseRewardCoins = 14,
        element = "Water", spawnWeight = 32,
        colorRGB = { 198, 223, 239 },
    },
    sunbeam = {
        id = "sunbeam", name = "Sunbeam Cloud", rarity = "Uncommon",
        baseCatchRadius = 9, baseRewardCoins = 22,
        element = "Light", spawnWeight = 15,
        colorRGB = { 255, 239, 171 },
    },
    thunder = {
        id = "thunder", name = "Thunder Cloud", rarity = "Rare",
        baseCatchRadius = 8, baseRewardCoins = 40,
        element = "Storm", spawnWeight = 8,
        colorRGB = { 115, 131, 182 },
    },
    frost = {
        id = "frost", name = "Frost Cloud", rarity = "Rare",
        baseCatchRadius = 9, baseRewardCoins = 36,
        element = "Ice", spawnWeight = 9,
        colorRGB = { 178, 236, 248 },
    },
    ember = {
        id = "ember", name = "Ember Cloud", rarity = "Rare",
        baseCatchRadius = 8, baseRewardCoins = 45,
        element = "Fire", spawnWeight = 7,
        colorRGB = { 255, 168, 112 },
    },
    rainbow = {
        id = "rainbow", name = "Rainbow Cloud", rarity = "Epic",
        baseCatchRadius = 7, baseRewardCoins = 80,
        element = "Light", spawnWeight = 3,
        colorRGB = { 250, 182, 231 },
    },
    twilight = {
        id = "twilight", name = "Twilight Cloud", rarity = "Epic",
        baseCatchRadius = 7, baseRewardCoins = 90,
        element = "Shadow", spawnWeight = 3,
        colorRGB = { 135, 115, 193 },
    },
    aurora = {
        id = "aurora", name = "Aurora Cloud", rarity = "Epic",
        baseCatchRadius = 7, baseRewardCoins = 100,
        element = "Nature", spawnWeight = 2,
        colorRGB = { 140, 241, 192 },
    },
    meteor = {
        id = "meteor", name = "Meteor Cloud", rarity = "Legendary",
        baseCatchRadius = 6, baseRewardCoins = 175,
        element = "Fire", spawnWeight = 1,
        colorRGB = { 255, 193, 102 },
    },
    moonveil = {
        id = "moonveil", name = "Moonveil Cloud", rarity = "Legendary",
        baseCatchRadius = 6, baseRewardCoins = 200,
        element = "Shadow", spawnWeight = 1,
        colorRGB = { 174, 182, 241 },
    },
    starfall = {
        id = "starfall", name = "Starfall Cloud", rarity = "Legendary",
        baseCatchRadius = 6, baseRewardCoins = 240,
        element = "Light", spawnWeight = 0.8,
        colorRGB = { 255, 232, 153 },
    },
    pollen = {
        id = "pollen", name = "Pollen Cloud", rarity = "Common",
        baseCatchRadius = 11, baseRewardCoins = 16,
        element = "Nature", spawnWeight = 25,
        colorRGB = { 227, 242, 162 },
    },
    moss = {
        id = "moss", name = "Moss Cloud", rarity = "Uncommon",
        baseCatchRadius = 10, baseRewardCoins = 24,
        element = "Nature", spawnWeight = 16,
        colorRGB = { 162, 213, 163 },
    },
    hail = {
        id = "hail", name = "Hail Cloud", rarity = "Uncommon",
        baseCatchRadius = 9, baseRewardCoins = 25,
        element = "Ice", spawnWeight = 14,
        colorRGB = { 205, 229, 251 },
    },
    monsoon = {
        id = "monsoon", name = "Monsoon Cloud", rarity = "Rare",
        baseCatchRadius = 8, baseRewardCoins = 55,
        element = "Water", spawnWeight = 6,
        colorRGB = { 116, 181, 222 },
    },
    voltage = {
        id = "voltage", name = "Voltage Cloud", rarity = "Epic",
        baseCatchRadius = 7, baseRewardCoins = 115,
        element = "Storm", spawnWeight = 2,
        colorRGB = { 176, 160, 251 },
    },
    nebula = {
        id = "nebula", name = "Nebula Cloud", rarity = "Mythic",
        baseCatchRadius = 5, baseRewardCoins = 400,
        element = "Cosmic", spawnWeight = 0.3,
        colorRGB = { 207, 140, 244 },
    },
}
return table.freeze(Catalog)

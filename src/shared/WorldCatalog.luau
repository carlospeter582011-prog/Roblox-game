-- World progression data. Pure; no Roblox globals.
-- Future Places will key off these ids. Starter island is world 0 / hub.
local Worlds = {
    sky_meadow = { id = "sky_meadow", name = "Sky Meadow", order = 1, unlockCatches = 0, theme = "Air", boss = "Meadow Warden" },
    rainfall_reef = { id = "rainfall_reef", name = "Rainfall Reef", order = 2, unlockCatches = 25, theme = "Water", boss = "Reef Leviathan" },
    thunder_peaks = { id = "thunder_peaks", name = "Thunder Peaks", order = 3, unlockCatches = 60, theme = "Storm", boss = "Stormheart Titan" },
    sunset_dunes = { id = "sunset_dunes", name = "Sunset Dunes", order = 4, unlockCatches = 100, theme = "Fire", boss = "Dune Pharaoh" },
    frost_spires = { id = "frost_spires", name = "Frost Spires", order = 5, unlockCatches = 150, theme = "Ice", boss = "Glacier Sentinel" },
    bloom_gardens = { id = "bloom_gardens", name = "Bloom Gardens", order = 6, unlockCatches = 200, theme = "Nature", boss = "Bloom Queen" },
    crystal_belt = { id = "crystal_belt", name = "Crystal Belt", order = 7, unlockCatches = 280, theme = "Earth", boss = "Crystal Colossus" },
    moonlit_isles = { id = "moonlit_isles", name = "Moonlit Isles", order = 8, unlockCatches = 360, theme = "Shadow", boss = "Moonveil Wraith" },
    stormheart_citadel = { id = "stormheart_citadel", name = "Stormheart Citadel", order = 9, unlockCatches = 450, theme = "Storm", boss = "Citadel Overlord" },
    lost_cloud_kingdom = { id = "lost_cloud_kingdom", name = "Lost Cloud Kingdom", order = 10, unlockCatches = 600, theme = "Cosmic", boss = "Kingdom Archon" },
}
return table.freeze(Worlds)

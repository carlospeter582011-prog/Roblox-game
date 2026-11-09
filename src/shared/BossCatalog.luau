-- Boss data. Pure; no Roblox globals.
-- Phased attacks and rewards will be implemented per world.
local Bosses = {
    meadow_warden = { id = "meadow_warden", name = "Meadow Warden", world = "sky_meadow", phases = 2, rewardCoins = 500, rewardXP = 250 },
    reef_leviathan = { id = "reef_leviathan", name = "Reef Leviathan", world = "rainfall_reef", phases = 3, rewardCoins = 800, rewardXP = 400 },
    stormheart_titan = { id = "stormheart_titan", name = "Stormheart Titan", world = "thunder_peaks", phases = 3, rewardCoins = 1200, rewardXP = 600 },
    dune_pharaoh = { id = "dune_pharaoh", name = "Dune Pharaoh", world = "sunset_dunes", phases = 2, rewardCoins = 1500, rewardXP = 750 },
    glacier_sentinel = { id = "glacier_sentinel", name = "Glacier Sentinel", world = "frost_spires", phases = 3, rewardCoins = 1800, rewardXP = 900 },
    bloom_queen = { id = "bloom_queen", name = "Bloom Queen", world = "bloom_gardens", phases = 2, rewardCoins = 2000, rewardXP = 1000 },
    crystal_colossus = { id = "crystal_colossus", name = "Crystal Colossus", world = "crystal_belt", phases = 4, rewardCoins = 2500, rewardXP = 1250 },
    moonveil_wraith = { id = "moonveil_wraith", name = "Moonveil Wraith", world = "moonlit_isles", phases = 3, rewardCoins = 3000, rewardXP = 1500 },
    citadel_overlord = { id = "citadel_overlord", name = "Citadel Overlord", world = "stormheart_citadel", phases = 4, rewardCoins = 4000, rewardXP = 2000 },
    kingdom_archon = { id = "kingdom_archon", name = "Kingdom Archon", world = "lost_cloud_kingdom", phases = 5, rewardCoins = 6000, rewardXP = 3000 },
}
return table.freeze(Bosses)

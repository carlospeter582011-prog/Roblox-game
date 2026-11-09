-- Story and side quests. Stable IDs. Server awards completion via CatchRules.
local Quests = {
    first_breeze = { id = "first_breeze", title = "A Whisper in the Sky", description = "Catch your first Breeze Cloud.", objective = "catch_species", speciesId = "breeze", required = 1, rewardCoins = 50, rewardXP = 25, chapter = 1 },
    three_clouds = { id = "three_clouds", title = "A Cloud Keeper's Beginning", description = "Catch three clouds to prepare for your journey.", objective = "total_catches", required = 3, rewardCoins = 80, rewardXP = 40, chapter = 1 },
    five_drizzle = { id = "five_drizzle", title = "Soft Rain", description = "Catch five Drizzle Clouds.", objective = "catch_species", speciesId = "drizzle", required = 5, rewardCoins = 120, rewardXP = 60, chapter = 1 },
    ten_total = { id = "ten_total", title = "Sky Collector", description = "Catch ten clouds of any kind.", objective = "total_catches", required = 10, rewardCoins = 150, rewardXP = 80, chapter = 1 },
    first_thunder = { id = "first_thunder", title = "A Distant Rumbling", description = "Catch your first Thunder Cloud.", objective = "catch_species", speciesId = "thunder", required = 1, rewardCoins = 200, rewardXP = 100, chapter = 2 },
    three_frost = { id = "three_frost", title = "Chill of the Heights", description = "Catch three Frost Clouds.", objective = "catch_species", speciesId = "frost", required = 3, rewardCoins = 180, rewardXP = 90, chapter = 2 },
    twenty_total = { id = "twenty_total", title = "Master of the Meadow", description = "Catch twenty clouds.", objective = "total_catches", required = 20, rewardCoins = 300, rewardXP = 150, chapter = 2 },
    first_rainbow = { id = "first_rainbow", title = "Colors of the Mystery", description = "Catch a Rainbow Cloud.", objective = "catch_species", speciesId = "rainbow", required = 1, rewardCoins = 400, rewardXP = 200, chapter = 3 },
    five_ember = { id = "five_ember", title = "Warm Currents", description = "Catch five Ember Clouds.", objective = "catch_species", speciesId = "ember", required = 5, rewardCoins = 250, rewardXP = 120, chapter = 2 },
    first_nebula = { id = "first_nebula", title = "Beyond the Veil", description = "Catch a Nebula Cloud.", objective = "catch_species", speciesId = "nebula", required = 1, rewardCoins = 1000, rewardXP = 500, chapter = 4 },
    ten_mist = { id = "ten_mist", title = "Morning Fog", description = "Catch ten Mist Clouds.", objective = "catch_species", speciesId = "mist", required = 10, rewardCoins = 200, rewardXP = 100, chapter = 2 },
    three_sunbeam = { id = "three_sunbeam", title = "Golden Hour", description = "Catch three Sunbeam Clouds.", objective = "catch_species", speciesId = "sunbeam", required = 3, rewardCoins = 220, rewardXP = 110, chapter = 2 },
    thirty_total = { id = "thirty_total", title = "Archipelago Pioneer", description = "Catch thirty clouds.", objective = "total_catches", required = 30, rewardCoins = 400, rewardXP = 200, chapter = 3 },
    first_aurora = { id = "first_aurora", title = "Northern Lights", description = "Catch an Aurora Cloud.", objective = "catch_species", speciesId = "aurora", required = 1, rewardCoins = 500, rewardXP = 250, chapter = 3 },
    five_crystal = { id = "five_crystal", title = "Shining Depths", description = "Catch five Crystal Clouds.", objective = "catch_species", speciesId = "crystal", required = 5, rewardCoins = 350, rewardXP = 175, chapter = 3 },
    first_void = { id = "first_void", title = "Edge of Nothing", description = "Catch a Void Cloud.", objective = "catch_species", speciesId = "void", required = 1, rewardCoins = 800, rewardXP = 400, chapter = 4 },
    fifty_total = { id = "fifty_total", title = "Sky Sovereign", description = "Catch fifty clouds.", objective = "total_catches", required = 50, rewardCoins = 600, rewardXP = 300, chapter = 4 },
    three_comet = { id = "three_comet", title = "Streaking Stars", description = "Catch three Comet Clouds.", objective = "catch_species", speciesId = "comet", required = 3, rewardCoins = 700, rewardXP = 350, chapter = 4 },
    first_solarflare = { id = "first_solarflare", title = "Heart of the Sun", description = "Catch a Solarflare Cloud.", objective = "catch_species", speciesId = "solarflare", required = 1, rewardCoins = 1200, rewardXP = 600, chapter = 5 },
    hundred_total = { id = "hundred_total", title = "Legend of the Clouds", description = "Catch one hundred clouds.", objective = "total_catches", required = 100, rewardCoins = 2000, rewardXP = 1000, chapter = 5 },
}
return table.freeze(Quests)

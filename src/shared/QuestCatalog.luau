-- Story quests have stable IDs; completion is awarded by server gameplay systems.
local Quests = {
    first_breeze = {
        id = "first_breeze",
        title = "A Whisper in the Sky",
        description = "Catch your first Breeze Cloud.",
        objective = "catch_species",
        speciesId = "breeze",
        required = 1,
        rewardCoins = 50,
        rewardXP = 25,
        chapter = 1,
    },
    three_clouds = {
        id = "three_clouds",
        title = "A Cloud Keeper's Beginning",
        description = "Catch three clouds to prepare for your journey.",
        objective = "total_catches",
        required = 3,
        rewardCoins = 80,
        rewardXP = 40,
        chapter = 1,
    },
}
return table.freeze(Quests)

-- Travel and progression data. Pure; no Roblox globals.
local Travel = {
    glide = { id = "glide", name = "Cloud Glide", unlockCatches = 5, speed = 1.2 },
    balloon = { id = "balloon", name = "Sky Balloon", unlockCatches = 30, speed = 1.5 },
    rideable = { id = "rideable", name = "Rideable Cloud", unlockCatches = 60, speed = 2.0 },
    skyship = { id = "skyship", name = "Skyship", unlockCatches = 120, speed = 2.5 },
    portal = { id = "portal", name = "World Portal", unlockCatches = 200, speed = 0 },
}
return table.freeze(Travel)

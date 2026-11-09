-- Island building data. Pure; no Roblox globals.
-- Placement, habitats and production will key off these ids.
local Islands = {
    starter = { id = "starter", name = "Starter Island", size = 1, unlockCatches = 0, theme = "Air" },
    meadow = { id = "meadow", name = "Meadow Isle", size = 2, unlockCatches = 20, theme = "Nature" },
    reef = { id = "reef", name = "Reef Platform", size = 2, unlockCatches = 40, theme = "Water" },
    peak = { id = "peak", name = "Peak Outpost", size = 3, unlockCatches = 80, theme = "Storm" },
    dune = { id = "dune", name = "Dune Terrace", size = 3, unlockCatches = 120, theme = "Fire" },
    spire = { id = "spire", name = "Frost Spire", size = 4, unlockCatches = 160, theme = "Ice" },
    garden = { id = "garden", name = "Bloom Garden", size = 4, unlockCatches = 200, theme = "Nature" },
    crystal = { id = "crystal", name = "Crystal Shelf", size = 5, unlockCatches = 280, theme = "Earth" },
    moon = { id = "moon", name = "Moonlit Dock", size = 5, unlockCatches = 360, theme = "Shadow" },
    citadel = { id = "citadel", name = "Citadel Landing", size = 6, unlockCatches = 450, theme = "Storm" },
}
return table.freeze(Islands)

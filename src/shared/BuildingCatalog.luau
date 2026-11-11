-- Island decoration catalog. Pure data. Placement and costs enforced server-side.
local Buildings = {
    lantern = { id = "lantern", name = "Sky Lantern", costCoins = 100, size = {x=2, y=4, z=2}, description = "A glowing lantern for your island." },
    flower = { id = "flower", name = "Flower Patch", costCoins = 50, size = {x=3, y=1, z=3}, description = "A colorful patch of flowers." },
    crystal = { id = "crystal", name = "Crystal Pedestal", costCoins = 200, size = {x=2, y=3, z=2}, description = "A pedestal holding a floating crystal." },
    bench = { id = "bench", name = "Sky Bench", costCoins = 150, size = {x=4, y=2, z=1.5}, description = "A place to rest and enjoy the view." },
}
return table.freeze(Buildings)

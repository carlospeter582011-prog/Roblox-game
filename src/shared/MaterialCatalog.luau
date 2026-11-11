-- Elemental materials dropped by catches. Used for crafting tools and upgrades.
-- Server awards based on caught cloud element and rarity.
local Materials = {
    air_essence = { id = "air_essence", name = "Air Essence", element = "Air", rarityWeight = 1 },
    water_droplet = { id = "water_droplet", name = "Water Droplet", element = "Water", rarityWeight = 1 },
    earth_shard = { id = "earth_shard", name = "Earth Shard", element = "Earth", rarityWeight = 1 },
    fire_spark = { id = "fire_spark", name = "Fire Spark", element = "Fire", rarityWeight = 1 },
    ice_crystal = { id = "ice_crystal", name = "Ice Crystal", element = "Ice", rarityWeight = 1 },
    light_mote = { id = "light_mote", name = "Light Mote", element = "Light", rarityWeight = 1 },
    shadow_wisp = { id = "shadow_wisp", name = "Shadow Wisp", element = "Shadow", rarityWeight = 1 },
    storm_charge = { id = "storm_charge", name = "Storm Charge", element = "Storm", rarityWeight = 1.2 },
    nature_seed = { id = "nature_seed", name = "Nature Seed", element = "Nature", rarityWeight = 1 },
    cosmic_dust = { id = "cosmic_dust", name = "Cosmic Dust", element = "Cosmic", rarityWeight = 1.5 },
}
return table.freeze(Materials)

-- Catching equipment data. Distinct gameplay effects are implemented by CloudCatch server.
local Tools = {
    starter_net = {name="Breeze Net",unlockCatches=0,rangeBonus=0,cooldown=0.5,coinMultiplier=1},
    wind_lasso = {name="Wind Lasso",unlockCatches=3,rangeBonus=4,cooldown=0.6,coinMultiplier=1},
    mist_gloves = {name="Mist Gloves",unlockCatches=8,rangeBonus=2,cooldown=0.3,coinMultiplier=1},
    cloud_magnet = {name="Cloud Magnet",unlockCatches=15,rangeBonus=7,cooldown=0.8,coinMultiplier=1},
    golden_net = {name="Golden Net",unlockCatches=30,rangeBonus=3,cooldown=0.55,coinMultiplier=1.5},
}
return table.freeze(Tools)

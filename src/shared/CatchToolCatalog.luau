-- Catching equipment data. Server enforces unlock, range, cooldown and coin multiplier.
local Tools = {
    starter_net = {name="Breeze Net",unlockCatches=0,rangeBonus=0,cooldown=0.5,coinMultiplier=1},
    wind_lasso = {name="Wind Lasso",unlockCatches=3,rangeBonus=4,cooldown=0.6,coinMultiplier=1},
    mist_gloves = {name="Mist Gloves",unlockCatches=8,rangeBonus=2,cooldown=0.3,coinMultiplier=1},
    cloud_magnet = {name="Cloud Magnet",unlockCatches=15,rangeBonus=7,cooldown=0.8,coinMultiplier=1},
    golden_net = {name="Golden Net",unlockCatches=30,rangeBonus=3,cooldown=0.55,coinMultiplier=1.5},
    storm_vacuum = {name="Storm Vacuum",unlockCatches=50,rangeBonus=10,cooldown=1.0,coinMultiplier=1.2},
    rainbow_lasso = {name="Rainbow Lasso",unlockCatches=75,rangeBonus=6,cooldown=0.4,coinMultiplier=1.8},
    cosmic_net = {name="Cosmic Net",unlockCatches=120,rangeBonus=8,cooldown=0.7,coinMultiplier=2.0},
}
return table.freeze(Tools)

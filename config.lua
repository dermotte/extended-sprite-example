-- config.lua
--- Central tuning values and asset paths for the sprite demo.

local Config = {}

Config.window = {
    title  = "Sprite Example",
    width  = 1920,
    height = 1080,
    msaa   = 4,
    -- Clamp frame spikes so fast missiles cannot tunnel through tanks.
    maxDt  = 1 / 30,
}

Config.assets = {
    map       = "assets/map.png",
    tank      = "assets/tank.png",
    tower     = "assets/tower.png",
    towerBase = "assets/tower_base.png",
    rocket    = "assets/rocket.png",
}

Config.tank = {
    moveSpeed      = 120,       -- pixels per second
    rotateDuration = 1.0,       -- seconds per 90-degree turn
    firstTurnX     = 64 * 15,   -- x where the tank turns downward
    turnDrop       = 64 * 4,    -- distance driven downward after the turn
    stopX          = 31 * 64,   -- final x where the tank stops
    spawnY         = 7 * 64,    -- base spawn row
    spawnSpread    = 32,        -- +/- random Y offset on spawn
}

Config.turret = {
    viewRange       = 64 * 6,   -- pixels
    fireRate        = 2.2,      -- seconds between shots
    missileMaxSpeed = 200,      -- pixels per second
    missileAccel    = 0.4,      -- seconds to reach full speed
    muzzleOffset    = 64,       -- pixels in front of turret centre
}

return Config

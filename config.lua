-- config.lua
--- Central tuning values, scene layout and asset paths for the sprite demo.
--- Read by conf.lua (window settings) and by every gameplay module.

local Config = {}

-- Window settings. conf.lua applies these before the window is created;
-- width/height also define the world bounds used for missile despawn.
Config.window = {
    title       = "Sprite Example",
    width       = 1920,
    height      = 1080,
    resizable   = false,
    msaa        = 4,
    orientation = "landscape",
    -- Clamp frame spikes so fast missiles cannot tunnel through tanks.
    maxDt       = 1 / 30,
}

-- Texture paths, resolved once and cached by sprite.lua.
Config.assets = {
    map       = "assets/map.png",
    tank      = "assets/tank.png",
    tower     = "assets/tower.png",
    towerBase = "assets/tower_base.png",
    rocket    = "assets/rocket.png",
}

-- Tank movement tuning.
Config.tank = {
    moveSpeed      = 120,       -- pixels per second
    rotateDuration = 1.0,       -- seconds per 90-degree turn
    firstTurnX     = 64 * 15,   -- x where the tank turns downward
    turnDrop       = 64 * 4,    -- distance driven downward after the turn
    stopX          = 31 * 64,   -- final x where the tank stops
    spawnY         = 7 * 64,    -- base spawn row
    spawnSpread    = 32,        -- +/- random Y offset on spawn
}

-- Turret targeting and firing tuning.
Config.turret = {
    viewRange       = 64 * 6,   -- pixels
    fireRate        = 2.2,      -- seconds between shots
    missileMaxSpeed = 200,      -- pixels per second
    missileAccel    = 0.4,      -- seconds to reach full speed
    muzzleOffset    = 64,       -- pixels in front of the turret centre
}

-- Initial scene layout.
Config.scene = {
    tankSpawns = {
        { x = 0,       y = Config.tank.spawnY },
        { x = -64 * 2, y = Config.tank.spawnY + 16 },
    },
    turrets = {
        { x = 64 * 12, y = 64 * 10 },
        { x = 64 * 18, y = 64 * 7 },
    },
    spawnEdgeX = -64,           -- x offset for tanks spawned with Space
}

return Config

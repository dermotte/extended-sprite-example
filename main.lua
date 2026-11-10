-- main.lua
--- Bootstraps the scene and runs the generic sprite loop.
---
--- Controls: Space spawns a tank; F11 toggles fullscreen.
local Config = require("config")
local Sprite = require("sprite")
local Tank   = require("tank")
local Turret = require("turret")

local sprites  = {}
local tanks    = {}
local missiles = {}

--- Shared context handed to every sprite's update().
local world = {
    sprites  = sprites,
    tanks    = tanks,
    missiles = missiles,
    width    = Config.window.width,
    height   = Config.window.height,
}

--- Creates a tank and registers it for update/draw and targeting.
--- @param x number top-left x
--- @param y number top-left y
local function addTank(x, y)
    local tank = Tank.new(Config.assets.tank, x, y)
    sprites[#sprites + 1] = tank
    tanks[#tanks + 1] = tank
end

--- Creates a turret together with its static base.
--- @param x number top-left x
--- @param y number top-left y
local function addTurret(x, y)
    sprites[#sprites + 1] = Sprite.new(Config.assets.towerBase, x, y)
    sprites[#sprites + 1] = Turret.new(Config.assets.tower, x, y)
end

--- Builds the initial scene from the layout in config.lua.
function love.load()
    if love.system.getOS() == "Android" then
        love.window.setMode(0, 0, { fullscreen = true })
    end

    -- Background must be added first so it draws underneath everything.
    sprites[#sprites + 1] = Sprite.new(Config.assets.map, 0, 0)

    for _, spawn in ipairs(Config.scene.tankSpawns) do
        addTank(spawn.x, spawn.y)
    end
    for _, spot in ipairs(Config.scene.turrets) do
        addTurret(spot.x, spot.y)
    end
end

--- Handles the demo's two keys: Space spawns a tank, F11 toggles fullscreen.
--- @param key string the pressed key
function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    elseif key == "space" then
        local spread = Config.tank.spawnSpread
        addTank(Config.scene.spawnEdgeX,
                Config.tank.spawnY + love.math.random(-spread, spread))
    end
end

--- Removes anything a behaviour flagged as dead this frame.
local function removeDead()
    for i = #sprites, 1, -1 do
        if sprites[i].dead then table.remove(sprites, i) end
    end
    for i = #tanks, 1, -1 do
        if tanks[i].dead then table.remove(tanks, i) end
    end
    for i = #missiles, 1, -1 do
        if missiles[i].dead then table.remove(missiles, i) end
    end
end

--- Updates every live sprite once, then sweeps dead objects.
--- @param dt number delta time in seconds
function love.update(dt)
    -- Clamp spikes so a slow frame cannot tunnel a missile through a tank.
    dt = math.min(dt, Config.window.maxDt)

    -- Snapshot the count: sprites spawned this frame start moving next frame.
    local count = #sprites
    for i = 1, count do
        local sprite = sprites[i]
        if not sprite.dead then
            sprite:update(dt, world)
        end
    end

    removeDead()
end

--- Draws every sprite in insertion order.
function love.draw()
    for i = 1, #sprites do
        sprites[i]:draw()
    end
end

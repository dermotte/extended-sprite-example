-- turret.lua
--- Turret: acquires the nearest tank in range, aims, and fires missiles.
--- Extends Sprite; only update() is overridden, drawing is inherited.
local Config = require("config")
local Sprite = require("sprite")
local Missile = require("missile")

-- math.atan2 exists on LuaJIT (Love 11); math.atan(y, x) is the Lua 5.3+ form.
local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end

local Turret = setmetatable({}, { __index = Sprite })
Turret.__index = Turret

local C = Config.turret

--- Creates a new turret.
--- @param imagePath string
--- @param x number
--- @param y number
--- @return table
function Turret.new(imagePath, x, y)
    local self = Sprite.new(imagePath, x, y)
    setmetatable(self, Turret)

    self.fireTimer = 0

    return self
end

--- Returns the nearest live tank within range, plus its offset from `self`.
local function findNearestTank(self, tanks)
    local cx, cy = self:getCenter()
    local rangeSq = C.viewRange * C.viewRange
    local bestDistSq, best, bestDX, bestDY = math.huge, nil, 0, 0

    for _, tank in ipairs(tanks) do
        if not tank.dead then
            local tx, ty = tank:getCenter()
            local dx, dy = tx - cx, ty - cy
            local distSq = dx * dx + dy * dy
            if distSq <= rangeSq and distSq < bestDistSq then
                bestDistSq, best, bestDX, bestDY = distSq, tank, dx, dy
            end
        end
    end

    return best, bestDX, bestDY
end

--- Aims at the nearest tank and fires a missile when the timer allows.
--- @param dt number delta time in seconds
--- @param world table shared context: { sprites, tanks, missiles, width, height }
function Turret:update(dt, world)
    local tank, dx, dy = findNearestTank(self, world.tanks)
    if not tank then return end

    -- Rotation 0 = facing up, so the facing vector is (sin r, -cos r).
    self.rotation = atan2(dx, -dy)

    local cx, cy = self:getCenter()
    local muzzleX = cx + math.sin(self.rotation) * C.muzzleOffset
    local muzzleY = cy - math.cos(self.rotation) * C.muzzleOffset

    self.fireTimer = self.fireTimer + dt
    if self.fireTimer < C.fireRate then return end
    self.fireTimer = self.fireTimer - C.fireRate

    -- The tank art faces RIGHT at rotation 0 (side view), so its forward
    -- vector is (cos r, sin r) and its nose sits half its width ahead.
    local tx, ty = tank:getCenter()
    local noseX = tx + math.cos(tank.rotation) * tank.w * 0.5
    local noseY = ty + math.sin(tank.rotation) * tank.w * 0.5
    local aim = atan2(noseX - muzzleX, -(noseY - muzzleY))

    local rocket = Missile.new(Config.assets.rocket, muzzleX, muzzleY,
                               aim, C.missileMaxSpeed, C.missileAccel)
    -- Centre the missile on the muzzle point (x/y are top-left corners).
    rocket.x = muzzleX - rocket.w * 0.5
    rocket.y = muzzleY - rocket.h * 0.5

    world.missiles[#world.missiles + 1] = rocket
    world.sprites[#world.sprites + 1] = rocket
end

return Turret

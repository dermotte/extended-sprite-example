-- missile.lua
--- Missile: flies forward with quadratic ease-in, despawns off-map,
--- and destroys the first tank it touches.
--- Extends Sprite; only update() is overridden, drawing is inherited.
local Sprite = require("sprite")

local Missile = setmetatable({}, { __index = Sprite })
Missile.__index = Missile

--- Creates a new missile.
--- @param imagePath string path to the texture
--- @param x number top-left x
--- @param y number top-left y
--- @param rotation number launch rotation (0 = facing up)
--- @param maxSpeed number pixels per second
--- @param accelDuration number seconds to reach full speed
--- @return table the new missile
function Missile.new(imagePath, x, y, rotation, maxSpeed, accelDuration)
    local self = Sprite.new(imagePath, x, y)
    setmetatable(self, Missile)

    self.rotation      = rotation or 0
    self.maxSpeed      = maxSpeed or 250
    self.accelDuration = accelDuration or 0.4
    self.accelTimer    = 0       -- seconds spent accelerating
    self.speed         = 0       -- current speed in pixels per second

    return self
end

--- Moves the missile, despawns it off-map, and on impact sets both the
--- missile and the tank `dead`.
--- @param dt number delta time in seconds
--- @param world table shared context: { sprites, tanks, missiles, width, height }
function Missile:update(dt, world)
    self.accelTimer = self.accelTimer + dt
    local t = math.min(self.accelTimer / self.accelDuration, 1)
    self.speed = self.maxSpeed * (t * t)   -- quadratic ease-in

    self.x = self.x + math.sin(self.rotation) * self.speed * dt
    self.y = self.y - math.cos(self.rotation) * self.speed * dt

    -- Retire the missile once it leaves the map.
    local margin = self.w
    if self.x < -margin or self.x > world.width + margin
       or self.y < -margin or self.y > world.height + margin then
        self.dead = true
        return
    end

    -- Circle collision against tank centres.
    local mx, my = self:getCenter()
    for _, tank in ipairs(world.tanks) do
        if not tank.dead then
            local tx, ty = tank:getCenter()
            local dx, dy = mx - tx, my - ty
            local hit = (self.w + tank.w) * 0.5
            if dx * dx + dy * dy <= hit * hit then
                self.dead = true
                tank.dead = true
                return
            end
        end
    end
end

return Missile

-- tank.lua
--- Tank: drives an autonomous path using a small state machine.
--- Extends Sprite; only update() is overridden, drawing is inherited.
---
--- States: moving_right -> rotating_down -> moving_down -> rotating_right ->
--- moving_right_2 -> stopped.
local Config = require("config")
local Sprite = require("sprite")

local Tank = setmetatable({}, { __index = Sprite })
Tank.__index = Tank

local C = Config.tank

--- Creates a new tank.
--- @param imagePath string path to the texture
--- @param x number top-left x
--- @param y number top-left y
--- @return table the new tank
function Tank.new(imagePath, x, y)
    local self = Sprite.new(imagePath, x, y)
    setmetatable(self, Tank)

    self.state       = "moving_right"
    self.rotateTimer = 0
    self.rotateStart = 0
    self.startY      = self.y

    return self
end

--- Rotates toward `target` over rotateDuration; returns true when done.
local function turnToward(self, target, dt)
    self.rotateTimer = self.rotateTimer + dt
    local t = math.min(self.rotateTimer / C.rotateDuration, 1)
    self.rotation = self.rotateStart + (target - self.rotateStart) * t
    return t >= 1
end

--- Advances the tank's movement state machine.
--- The inherited world context is unused; tanks need no scene data.
--- @param dt number delta time in seconds
function Tank:update(dt)
    if self.state == "moving_right" then
        self.x = self.x + C.moveSpeed * dt
        if self.x >= C.firstTurnX then
            self.x = C.firstTurnX
            self.state = "rotating_down"
            self.rotateTimer = 0
            self.rotateStart = self.rotation
        end

    elseif self.state == "rotating_down" then
        if turnToward(self, self.rotateStart + math.pi / 2, dt) then
            self.state = "moving_down"
        end

    elseif self.state == "moving_down" then
        self.y = self.y + C.moveSpeed * dt
        if self.y - self.startY >= C.turnDrop then
            self.y = self.startY + C.turnDrop
            self.state = "rotating_right"
            self.rotateTimer = 0
            self.rotateStart = self.rotation
        end

    elseif self.state == "rotating_right" then
        if turnToward(self, self.rotateStart - math.pi / 2, dt) then
            self.state = "moving_right_2"
        end

    elseif self.state == "moving_right_2" then
        self.x = self.x + C.moveSpeed * dt
        if self.x >= C.stopX then
            self.x = C.stopX
            self.state = "stopped"
        end
    end
end

return Tank

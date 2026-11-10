-- sprite.lua
--- Base Sprite class.
---
--- The whole scene is updated and drawn generically: main.lua only ever calls
--- `sprite:update(dt, world)` and `sprite:draw()`. The base class owns drawing
--- and declares the update hook; each subclass supplies its own behaviour by
--- overriding update().
local Sprite = {}
Sprite.__index = Sprite

-- Textures are decoded once per path and shared by every sprite that uses them.
local imageCache = {}

local function loadImage(path)
    local img = imageCache[path]
    if not img then
        img = love.graphics.newImage(path)
        imageCache[path] = img
    end
    return img
end

--- Creates a new sprite.
--- @param imagePath string path to the texture
--- @param x number top-left x
--- @param y number top-left y
--- @return table
function Sprite.new(imagePath, x, y)
    local img = loadImage(imagePath)
    return setmetatable({
        img      = img,
        w        = img:getWidth(),
        h        = img:getHeight(),
        x        = x or 0,
        y        = y or 0,
        rotation = 0,
        scale    = 1,
        dead     = false,   -- behaviours set this; main.lua sweeps it up
    }, Sprite)
end

--- Per-frame behaviour hook. Static sprites inherit this empty version.
--- @param dt number delta time in seconds
--- @param world table shared context: { sprites, tanks, missiles, width, height }
function Sprite:update(dt, world)
end

--- Centre of the sprite in world space.
--- @return number x, number y
function Sprite:getCenter()
    return self.x + self.w * 0.5, self.y + self.h * 0.5
end

--- Draws the sprite centred on its position, rotating around its middle.
function Sprite:draw()
    local cx, cy = self.w * 0.5, self.h * 0.5
    love.graphics.draw(self.img, self.x + cx, self.y + cy,
                       self.rotation, self.scale, self.scale, cx, cy)
end

return Sprite

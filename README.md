# Sprite Example

A Love2D (LÖVE) demonstration of a sprite class system with inheritance, autonomous movement, turret targeting, and projectile combat.

## Getting Started

### Prerequisites

- [LÖVE (Love2D)](https://love2d.org/) version 11.5 or later

### Running the Demo

From the project directory:

```bash
love .
```

Or specify the folder explicitly:

```bash
love d:/projects/love2d/sprite-example
```

### Controls

| Key | Action |
|-----|--------|
| **Space** | Spawn a new tank at the left edge (randomized Y offset) |
| **F11** | Toggle fullscreen mode |

## Project Structure

```
sprite-example/
├── assets/            # Image assets (tank.png, tower.png, rocket.png, map.png, etc.)
├── config.lua         # Central tuning values and asset paths
├── conf.lua           # LÖVE window configuration (title, size, fullscreen, etc.)
├── main.lua           # Entry point; love.load/update/draw, scene tables, world context
├── missile.lua        # Missile class (extends Sprite) with eased-in movement
├── sprite.lua         # Base Sprite class (draw + update hook, texture cache)
├── tank.lua           # Tank class (extends Sprite) with state machine movement
├── turret.lua         # Turret class (extends Sprite) with targeting + firing
└── README.md          # This file
```

### File Descriptions

| File | Purpose |
|------|---------|
| `sprite.lua` | Base `Sprite` class. Owns the texture cache, centre-anchored drawing, and an empty `update()` hook that subclasses override. |
| `tank.lua` | `Tank` class extending `Sprite`. Overrides `update()` with an autonomous state machine (move right → rotate → move down → rotate back → move right → stop). |
| `turret.lua` | `Turret` class extending `Sprite`. Overrides `update()` to track the nearest tank in range, rotate toward it, and fire missiles at a fixed rate. |
| `missile.lua` | `Missile` class extending `Sprite`. Overrides `update()` with quadratic ease-in movement, off-map despawn, and tank collision. |
| `main.lua` | Bootstraps the scene, holds the shared `world` context (`sprites`, `tanks`, `missiles`), and runs the generic update/draw loops plus input. |
| `config.lua` | Central tuning values (window, tank, turret, assets) used by the other modules. |
| `conf.lua` | LÖVE window configuration (1920×1080, non-resizable, MSAA 4x), read from `config.lua`. |

## Sprite System

### Base Sprite Class

The `Sprite` class (`sprite.lua`) is implemented as a Lua table using metatables for prototype-based inheritance:

```lua
local Sprite = {}
Sprite.__index = Sprite

function Sprite.new(imagePath, x, y)
    local img = loadImage(imagePath)   -- cached by path
    return setmetatable({
        img = img,
        w = img:getWidth(),
        h = img:getHeight(),
        x = x or 0,
        y = y or 0,
        scale = 1,
        rotation = 0,
        dead = false
    }, Sprite)
end
```

Key design points:

- **Instances are plain tables** with a metatable whose `__index` points to `Sprite`. Any method defined on `Sprite` (e.g. `Sprite:draw`, `Sprite:getCenter`) is available on all instances unless overridden.
- **`Sprite:draw()`** renders the sprite centered at `(x + w/2, y + h/2)`, rotating around its center. The `x`/`y` fields store the top-left corner; the drawing function adds half-width/half-height as the origin offset so rotation is always around the sprite's center.
- **`Sprite:update(dt, world)`** is the shared behaviour hook. The base version is empty (static sprites); subclasses override it to add movement, targeting, or collision. `main.lua` calls it generically on every object, so behaviour lives entirely in the subclass.
- **`dead`** is a flag a subclass can set during `update()`; `main.lua` sweeps dead objects out of the scene tables after updating.

### Extending Sprite (Inheritance)

Subclasses like `Tank`, `Turret`, and `Missile` follow the same two-step metatable pattern:

```lua
-- 1. The class table inherits from Sprite
setmetatable(Tank, { __index = Sprite })

-- 2. Each instance inherits from the class table
function Tank.new(imagePath, x, y)
    local self = Sprite.new(imagePath, x, y)
    setmetatable(self, { __index = Tank })
    -- add Tank-specific fields...
    return self
end
```

This creates a prototype chain:

```
Instance → Tank → Sprite
```

Methods not found on the instance are looked up on `Tank`, then on `Sprite`.

### Object Lists

`main.lua` keeps three tables and passes them to every sprite through a shared `world` context:

- `sprites` — the unified render/update list (background map, static tower bases, tanks, turrets, missiles)
- `tanks` — live tanks, used by turrets for targeting and by missiles for collision
- `missiles` — active missiles, swept for despawn/removal

`love.update` runs a single generic loop: it snapshots the sprite count (so a missile spawned mid-frame starts moving next frame), calls `sprite:update(dt, world)` on each live sprite, then removes anything flagged `dead`. `love.draw` similarly calls `sprite:draw()` on every sprite in order.

Behaviours live entirely in the subclass `update()` methods:

- `Tank:update` advances the movement state machine.
- `Turret:update` finds the nearest live tank in `world.tanks`, aims, and appends a new missile to `world.missiles` and `world.sprites`.
- `Missile:update` accelerates, despawns off-map, and on collision sets both itself and the tank `dead`.

## License

The assets of this project are from Kenney.nl, please consult the web page to obtain information regarding the asset license. 

This project's source code is licensed under the **MIT License**.

```
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

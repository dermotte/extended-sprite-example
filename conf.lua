-- conf.lua
--- LÖVE window configuration, sourced from config.lua.
local Config = require("config")

--- Applies the window settings before the window is created.
--- @param t table the LÖVE configuration table
function love.conf(t)
    t.window.title       = Config.window.title
    t.window.width       = Config.window.width
    t.window.height      = Config.window.height
    t.window.resizable   = Config.window.resizable
    t.window.msaa        = Config.window.msaa
    t.window.orientation = Config.window.orientation
end

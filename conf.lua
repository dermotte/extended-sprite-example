-- conf.lua
--- LÖVE window configuration, sourced from config.lua.
local Config = require("config")

function love.conf(t)
    t.window.title       = Config.window.title
    t.window.width       = Config.window.width
    t.window.height      = Config.window.height
    t.window.resizable   = false
    t.window.msaa        = Config.window.msaa
    t.window.orientation = "landscape"
end

charthandler = require("charthandler")
Timer = require("lib.Timer")
ffi = require("ffi")

ffi.cdef[[
    typedef union {
        int32_t i32;
        char bytes[4];
    } int32_union;
]]

Timer.after(0.15, function() 
    audio:play()
    if bg then bg:play() end
    Timer.after(DELAY, function()
        canUpdate = true
    end)
end)

states = {
    game = require("states.game"),
}

local currentstate = states.game

function love.update(dt)
    currentstate:update(dt)
    Timer.update(dt)
end

function love.keypressed(key)
    currentstate:keypressed(key)
end

function love.draw()
    currentstate:draw()

    love.graphics.setColor(0, 0, 0)
    for x = -1, 1 do
        for y = -1, 1 do
            love.graphics.print(love.timer.getFPS(), 5+x, 5+y)
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 5, 5)
end
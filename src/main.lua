charthandler = require("modules.SongHandler")
songPackHandler = require("modules.SongPackHandler")
Timer = require("lib.Timer")
State = require("lib.State")
ffi = require("ffi")

ffi.cdef[[
    typedef union {
        int32_t i32;
        char bytes[4];
    } int32_union;
]]

states = {
    game = require("states.Game"),
}

State.switch(states.game)

function love.load()
    love.filesystem.createDirectory("SongPacks")
end

function love.update(dt)
    State.update(dt)
    Timer.update(dt)
end

function love.keypressed(key)
    State.keypressed(key)
end

function love.draw()
    State.draw()

    love.graphics.setColor(0, 0, 0)
    for x = -1, 1 do
        for y = -1, 1 do
            love.graphics.print(love.timer.getFPS(), 5+x, 5+y)
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 5, 5)
end
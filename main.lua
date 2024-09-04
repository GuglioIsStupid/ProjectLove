charthandler = require("charthandler")
Timer = require("Timer")
ffi = require("ffi")
-- Define a structure to read 32-bit integers from binary data
ffi.cdef[[
    typedef union {
        int32_t i32;
        char bytes[4];
    } int32_union;
]]

local assetsRef = {
    love.graphics.newImage("left_note.png"),
    love.graphics.newImage("down_note.png"),
    love.graphics.newImage("up_note.png"),
    love.graphics.newImage("right_note.png"),
    love.graphics.newImage("slide_chain_piece_left_note.png"),
    love.graphics.newImage("slide_chain_piece_right_note.png"),
    love.graphics.newImage("slide_chain_piece_left_target.png"),
    love.graphics.newImage("slide_chain_piece_right_target.png"),
}

local dial = love.graphics.newImage("dial.png")

local chart = processFile("pv_764_extreme.dsc")
audio = love.audio.newSource("pv_764.ogg", "stream")

notes = {}
counter = 1
timer = 0
flyTime = 100000
finished = false
current = 0
mask = 0
mask2 = 00
statTimer = 0
holdNotes = 0
holdStart = 0
holdTimer = 0
holdScore = 0
slideCount = 0
slideBroken = false
combo = 0
life = 127
results = {}
DELAY = 0

currentTft = 750

love.audio.setVolume(0.25)

spawned = {
    targets = {},
    moving = {}
}

local function initializeLinearMove(note, target)
    local distanceX = target.x - note.x
    local distanceY = target.y - note.y
    local duration = note.tft / 1000

    note.velocityX = distanceX / duration
    note.velocityY = distanceY / duration
    note.duration = duration
end

function setTarget(command, musicTime)
    table.insert(notes, {
        type = command.params[1],
        holdTimer = command.params[2],
        holdEnd = command.params[3],
        x = (command.params[2]) * 0.002666667,
        y = (command.params[3]) * 0.002666667,
        angle = (command.params[4]),
        wavecount = command.params[7],
        distance = (command.params[5]),
        amplitude = (command.params[5]),
        tft = command.params[10] or currentTft,
        ts = command.params[11],
        time = musicTime
    })
end

local lastTarget = nil
local function spawnTarget(tgt)
    local target = {
        x = tgt.x,
        y = tgt.y,
        type = tgt.type,
    }
    target.visible = true

    table.insert(spawned.targets, target)

    local note = {}

    note.x = (tgt.x + math.sin((tgt.angle/1000) * math.pi / 180) * (tgt.distance/500))
    note.y = (tgt.y - math.cos((tgt.angle/1000) * math.pi / 180) * (tgt.distance/500))
    note.parent = target
    target.note = note
    note.visible = true
    note.angle = tgt.angle
    note.distance = tgt.distance
    note.time = tgt.time
    note.tft = tgt.tft
    note.hitTime = tgt.time + tgt.tft*100
    note.shrinkTime = tgt.time + tgt.tft*110
    note.scale = 1
    note.dialAngle = 0

    table.insert(spawned.moving, note)
    note.id = #spawned.moving
    note.tgtID = #spawned.targets
    
    note.showDial = true

    local imgID = 0
    local type = tgt.type

    if lastTarget then
        if type == lastTarget.type and target.x < lastTarget.x and target.y == target.y then
            if type == 12 then
                type = 15
            elseif type == 16 then
                type = 13
                
            end
        end

        lastTarget = tgt
    end

    if type == 0 or type == 4 or type == 8 or type == 18 then
        imgID = 3
    elseif type == 1 or type == 5 or type == 9 or type == 19 then
        imgID = 4
    elseif type == 2 or type == 6 or type == 10 or type == 20 then
        imgID = 2
    elseif type == 3 or type == 7 or type == 11 or type == 21 then
        imgID = 1
    elseif type == 12 then
        imgID = 5
    elseif type == 13 then
        imgID = 6
    elseif type == 15 then
        imgID = 7
        note.showDial = false
    else
        imgID = 8
        note.showDial = false
    end

    target.imgID = imgID
    note.imgID = imgID

    lastTarget = tgt

    initializeLinearMove(note, target)
end

musicTime = 0
canUpdate = false

--[[ bg = love.graphics.newVideo("video.ogv") ]]

Timer.after(1, function() 
    audio:play()
    if bg then bg:play() end
    Timer.after(DELAY, function()
        canUpdate = true
    end)
end)

function love.update(dt)
    if canUpdate then
        musicTime = musicTime + 100000 * dt
    end
    Timer.update(dt)

    for i, event in ipairs(chart) do
        if (event.time < musicTime) then
            if event.type == "TARGET" then
                setTarget(event, musicTime)
                spawnTarget(notes[#notes])
            elseif event.type == "BAR_TIME_SET" then
                bpm = event.params[1]
                currentTft = 1000 / (bpm / ((event.params[2] + 1) * 60))
            elseif event.type == "TARGET_FLYING_TIME" then
                currentTft = event.params[1]
                bpm = 240000 / currentTft
            end

            table.remove(chart, i)
        end
    end

    for _, note in ipairs(spawned.moving) do
        note.x = note.x + note.velocityX * dt
        note.y = note.y + note.velocityY * dt

        local elapsedTime = musicTime - note.time
        local duration = note.hitTime - note.time

        note.dialAngle = (elapsedTime / duration) * 360
        
        if musicTime > note.hitTime then
            local remainingTime = note.shrinkTime - musicTime
            local totalShrinkDuration = note.shrinkTime - note.hitTime

            note.scale = math.max(0, remainingTime / totalShrinkDuration)

            if note.scale <= 0 then
                note.visible = false
                note.parent.visible = false
            end

            if note.scale <= 0 then
                note.visible = false
                note.parent.visible = false
            end
        end
    end
end

function love.draw()
    if bg then
        love.graphics.draw(bg, 0, 0, 0, 1280/bg:getWidth(), 720/bg:getHeight())
    end

    love.graphics.setColor(0, 0, 0)
    for x = -1, 1 do
        for y = -1, 1 do
            love.graphics.print(love.timer.getFPS(), 5+x, 5+y)
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 5, 5)

    for _, target in ipairs(spawned.targets) do
        if target.visible then
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.draw(assetsRef[target.imgID], target.x, target.y, 0, 1, 1, assetsRef[target.imgID]:getWidth()/2, assetsRef[target.imgID]:getHeight()/2)

            if target.note.showDial then
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(dial, target.x, target.y, math.rad(target.note.dialAngle), 0.9, 0.9, dial:getWidth()/2, dial:getHeight()-11)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    for _, moving in ipairs(spawned.moving) do
        if moving.visible then
            love.graphics.draw(assetsRef[moving.imgID], moving.x, moving.y, 0, moving.scale, moving.scale, assetsRef[moving.imgID]:getWidth()/2, assetsRef[moving.imgID]:getHeight()/2)
        end
    end
end
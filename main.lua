charthandler = require("charthandler")
Timer = require("Timer")
ffi = require("ffi")

ffi.cdef[[
    typedef union {
        int32_t i32;
        char bytes[4];
    } int32_union;
]]

local assetsRefNormal = {
    love.graphics.newImage("left_note.png"),
    love.graphics.newImage("down_note.png"),
    love.graphics.newImage("up_note.png"),
    love.graphics.newImage("right_note.png"),
    love.graphics.newImage("slide_left_note.png"),
    love.graphics.newImage("slide_right_note.png"),
    love.graphics.newImage("slide_chain_piece_left_note.png"),
    love.graphics.newImage("slide_chain_piece_right_note.png"),
}

local assetsRefTarget = {
    love.graphics.newImage("left_target.png"),
    love.graphics.newImage("down_target.png"),
    love.graphics.newImage("up_target.png"),
    love.graphics.newImage("right_target.png"),
    love.graphics.newImage("slide_left_target.png"),
    love.graphics.newImage("slide_right_target.png"),
    love.graphics.newImage("slide_chain_piece_left_target.png"),
    love.graphics.newImage("slide_chain_piece_right_target.png"),
}

local assetsDoubleRefNormal = {
    love.graphics.newImage("left_multi_note.png"),
    love.graphics.newImage("down_multi_note.png"),
    love.graphics.newImage("up_multi_note.png"),
    love.graphics.newImage("right_multi_note.png"),
    love.graphics.newImage("slide_left_multi_note.png"),
    love.graphics.newImage("slide_right_multi_note.png")
}

local assetsDoubleRefTarget = {
    love.graphics.newImage("left_multi_note_target.png"),
    love.graphics.newImage("down_multi_note_target.png"),
    love.graphics.newImage("up_multi_note_target.png"),
    love.graphics.newImage("right_multi_note_target.png"),
    love.graphics.newImage("slide_left_multi_note_target.png"),
    love.graphics.newImage("slide_right_multi_note_target.png")
}

local dial = love.graphics.newImage("dial.png")
local hitsound = love.audio.newSource("hitsound.wav", "static")
local slidehitsound = love.audio.newSource("slidehitsound.wav", "static")
local chart = processFile("pv_3147_hard.dsc")
audio = love.audio.newSource("pv_3147.ogg", "stream")

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
        time = musicTime,
        isDouble = command.params[12]
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
    note.scale = 0.9
    note.dialAngle = 0
    note.isDouble = tgt.isDouble

    table.insert(spawned.moving, note)
    note.id = #spawned.moving
    note.tgtID = #spawned.targets
    
    note.showDial = true

    local imgID = 0
    local type = tgt.type

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

    local dontForceLols = false
    if lastTarget and (lastTarget.imgID == 7 or lastTarget.imgID == 8) and not lastTarget.dontDoIt then
        if lastTarget.imgID == 7 then
            lastTarget.imgID = 5
            lastTarget.note.imgID = 5
            lastTarget.showDial = true
        else    
            lastTarget.imgID = 6
            lastTarget.note.imgID = 6
            lastTarget.showDial = true
        end

        dontForceLols = true
    end

    target.dontDoIt = dontForceLols

    lastTarget = target

    initializeLinearMove(note, target)
end

musicTime = 0
canUpdate = false

bg = love.graphics.newVideo("pv_3147.ogv")

Timer.after(0.15, function() 
    audio:play()
    if bg then bg:play() end
    Timer.after(DELAY, function()
        canUpdate = true
    end)
end)

local inputs = {
    {"a", "j", id = 3, sound=1},
    {"s", "k", id = 4, sound=1},
    {"w", "i", id = 2, sound=1},
    {"d", "l", id = 1, sound=1},
    {"q", "u", id = 5, sound=2},
    {"e", "o", id = 6, sound=2}
}

local sounds = {
    love.audio.newSource("hitsound.wav", "static"),
    love.audio.newSource("slidehitsound.wav", "static")
}

local holdInputs = {
    {"q", "u", id = 7},
    {"e", "o", id = 8}
}

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

            note.scale = math.max(0, remainingTime / totalShrinkDuration * 0.9)

            if note.scale <= 0 then
                note.visible = false
                note.parent.visible = false
            end

            if note.scale <= 0 then
                note.visible = false
                note.parent.visible = false
            end
        end

        for i, input in ipairs(holdInputs) do
            if love.keyboard.isDown(input[1]) or love.keyboard.isDown(input[2]) then
                local absTime = math.abs(musicTime - note.hitTime)
                if absTime < 1000 then
                    -- hit !
                    note.visible = false
                    note.parent.visible = false
                    combo = combo + 1
                end
            end
        end
    end
end

function love.keypressed(key)
    for i, v in ipairs(inputs) do
       if key == v[1] or key == v[2] then
            sounds[v.sound]:clone():play()
        end
    end
    for i, moving in ipairs(spawned.moving) do
        if moving.visible and moving.imgID < 7 then
            if key == inputs[moving.imgID][1] or key == inputs[moving.imgID][2] then
                local absTime = math.abs(musicTime - moving.hitTime)

                if absTime < 20000 then
                    if moving.isDouble then
                        if moving.parent.imgID == 5 then
                            moving.parent.imgID = 7
                            moving.parent.note.imgID = 7
                        else
                            moving.parent.imgID = 8
                            moving.parent.note.imgID = 8
                        end
                    end

                    moving.visible = false
                    moving.parent.visible = false
                    combo = combo + 1

                    break
                end
            end
        end
    end
end

function love.draw()
    if bg then
        love.graphics.draw(bg, 0, 0, 0, 1280/bg:getWidth(), 720/bg:getHeight())
    end

    for _, target in ipairs(spawned.targets) do
        if target.visible then
            if not target.note.isDouble then
                love.graphics.draw(assetsRefTarget[target.imgID], target.x, target.y, 0, 0.9, 0.9, assetsRefTarget[target.imgID]:getWidth()/2, assetsRefTarget[target.imgID]:getHeight()/2)
            else
                love.graphics.draw(assetsDoubleRefTarget[target.imgID], target.x, target.y, 0, 0.9, 0.9, assetsDoubleRefTarget[target.imgID]:getWidth()/2, assetsDoubleRefTarget[target.imgID]:getHeight()/2)
            end

            if target.note.showDial then
                love.graphics.draw(dial, target.x, target.y, math.rad(target.note.dialAngle), 0.9, 0.9, dial:getWidth()/2, dial:getHeight()-11)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    for _, moving in ipairs(spawned.moving) do
        if moving.visible then
            --love.graphics.draw(assetsRefNormal[moving.imgID], moving.x, moving.y, 0, moving.scale, moving.scale, assetsRefNormal[moving.imgID]:getWidth()/2, assetsRefNormal[moving.imgID]:getHeight()/2)
            if not moving.isDouble then
                love.graphics.draw(assetsRefNormal[moving.imgID], moving.x, moving.y, 0, moving.scale, moving.scale, assetsRefNormal[moving.imgID]:getWidth()/2, assetsRefNormal[moving.imgID]:getHeight()/2)
            else
                love.graphics.draw(assetsDoubleRefNormal[moving.imgID], moving.x, moving.y, 0, moving.scale, moving.scale, assetsDoubleRefNormal[moving.imgID]:getWidth()/2, assetsDoubleRefNormal[moving.imgID]:getHeight()/2)
            end
        end
    end

    love.graphics.setColor(0, 0, 0)
    for x = -1, 1 do
        for y = -1, 1 do
            love.graphics.print(love.timer.getFPS(), 5+x, 5+y)
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 5, 5)
end
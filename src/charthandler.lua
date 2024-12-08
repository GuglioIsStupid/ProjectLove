-- Thanks to https://github.com/nastys/nastys.github.io/blob/master/dsceditor
-- otherwise i would have never been able to figure out how this shit works

local handler = {}

local paramCounts = {
    [105] = {opcode = "AGEAGE_CTRL", len = 8},
    [46] = {opcode = "AIM", len = 3},
    [97] = {opcode = "AOTO_CAP", len = 1},
    [56] = {opcode = "AUTO_BLINK", len = 2},
    [28] = {opcode = "BAR_TIME_SET", len = 2},
    [93] = {opcode = "BLOOM", len = 2},
    [14] = {opcode = "CHANGE_FIELD", len = 1},
    [96] = {opcode = "CHARA_ALPHA", len = 4},
    [72] = {opcode = "CHARA_COLOR", len = 2},
    [60] = {opcode = "CHARA_HEIGHT_ADJUST", len = 2},
    [103] = {opcode = "CHARA_LIGHT", len = 3},
    [62] = {opcode = "CHARA_POS_ADJUST", len = 4},
    [59] = {opcode = "CHARA_SIZE", len = 2},
    [50] = {opcode = "CLOTH_WET", len = 2},
    [94] = {opcode = "COLOR_COLLE", len = 3},
    [13] = {opcode = "DATA_CAMERA", len = 2},
    [66] = {opcode = "DATA_CAMERA_START", len = 2},
    [95] = {opcode = "DOF", len = 3},
    [48] = {opcode = "EDIT_BLUSH", len = 1},
    [81] = {opcode = "EDIT_CAMERA", len = 24},
    [44] = {opcode = "EDIT_DISP", len = 1},
    [43] = {opcode = "EDIT_EFFECT", len = 2},
    [78] = {opcode = "EDIT_EXPRESSION", len = 2},
    [41] = {opcode = "EDIT_EYE", len = 2},
    [40] = {opcode = "EDIT_EYELID", len = 1},
    [75] = {opcode = "EDIT_EYELID_ANIM", len = 3},
    [79] = {opcode = "EDIT_EYE_ANIM", len = 3},
    [30] = {opcode = "EDIT_FACE", len = 1},
    [45] = {opcode = "EDIT_HAND_ANIM", len = 2},
    [76] = {opcode = "EDIT_INSTRUMENT_ITEM", len = 2},
    [42] = {opcode = "EDIT_ITEM", len = 1},
    [34] = {opcode = "EDIT_LYRIC", len = 2},
    [82] = {opcode = "EDIT_MODE_SELECT", len = 1},
    [27] = {opcode = "EDIT_MOTION", len = 4},
    [91] = {opcode = "EDIT_MOTION_F", len = 6},
    [77] = {opcode = "EDIT_MOTION_LOOP", len = 4},
    [64] = {opcode = "EDIT_MOT_SMOOTH_LEN", len = 2},
    [36] = {opcode = "EDIT_MOUTH", len = 1},
    [80] = {opcode = "EDIT_MOUTH_ANIM", len = 2},
    [38] = {opcode = "EDIT_MOVE", len = 7},
    [74] = {opcode = "EDIT_MOVE_XYZ", len = 9},
    [39] = {opcode = "EDIT_SHADOW", len = 1},
    [35] = {opcode = "EDIT_TARGET", len = 5},
    [11] = {opcode = "EFFECT_OFF", len = 1},
    [9] = {opcode = "EFFECT", len = 6},
    [0] = {opcode = "END", len = 0},
    [22] = {opcode = "EXPRESSION", len = 4},
    [18] = {opcode = "EYE_ANIM", len = 3},
    [89] = {opcode = "FACE_TYPE", len = 1},
    [10] = {opcode = "FADEIN_FIELD", len = 2},
    [17] = {opcode = "FADEOUT_FIELD", len = 2},
    [55] = {opcode = "FADE_MODE", len = 1},
    [92] = {opcode = "FOG", len = 3},
    [20] = {opcode = "HAND_ANIM", len = 5},
    [47] = {opcode = "HAND_ITEM", len = 3},
    [87] = {opcode = "HAND_SCALE", len = 3},
    [15] = {opcode = "HIDE_FIELD", len = 1},
    [101] = {opcode = "ITEM_ALPHA", len = 4},
    [61] = {opcode = "ITEM_ANIM", len = 4},
    [85] = {opcode = "ITEM_ANIM_ATTACH", len = 3},
    [88] = {opcode = "LIGHT_POS", len = 4},
    [51] = {opcode = "LIGHT_ROT", len = 3},
    [21] = {opcode = "LOOK_ANIM", len = 4},
    [23] = {opcode = "LOOK_CAMERA", len = 5},
    [24] = {opcode = "LYRIC", len = 2},
    [98] = {opcode = "MAN_CAP", len = 1},
    [4] = {opcode = "MIKU_DISP", len = 2},
    [2] = {opcode = "MIKU_MOVE", len = 4},
    [3] = {opcode = "MIKU_ROT", len = 2},
    [5] = {opcode = "MIKU_SHADOW", len = 2},
    [26] = {opcode = "MODE_SELECT", len = 2},
    [19] = {opcode = "MOUTH_ANIM", len = 5},
    [31] = {opcode = "MOVE_CAMERA", len = 21},
    [16] = {opcode = "MOVE_FIELD", len = 3},
    [102] = {opcode = "MOVIE_CUT_CHG", len = 2},
    [68] = {opcode = "MOVIE_DISP", len = 1},
    [67] = {opcode = "MOVIE_PLAY", len = 1},
    [25] = {opcode = "MUSIC_PLAY", len = 0},
    [49] = {opcode = "NEAR_CLIP", len = 2},
    [71] = {opcode = "OSAGE_MV_CCL", len = 3},
    [70] = {opcode = "OSAGE_STEP", len = 3},
    [57] = {opcode = "PARTS_DISP", len = 3},
    [106] = {opcode = "PSE", len = 2},
    [65] = {opcode = "PV_BRANCH_MODE", len = 1},
    [32] = {opcode = "PV_END", len = 0},
    [83] = {opcode = "PV_END_FADEOUT", len = 2},
    [54] = {opcode = "SATURATE", len = 1},
    [52] = {opcode = "SCENE_FADE", len = 6},
    [63] = {opcode = "SCENE_ROT", len = 1},
    [12] = {opcode = "SET_CAMERA", len = 6},
    [37] = {opcode = "SET_CHARA", len = 1},
    [7] = {opcode = "SET_MOTION", len = 4},
    [8] = {opcode = "SET_PLAYDATA", len = 2},
    [73] = {opcode = "SE_EFFECT", len = 1},
    [29] = {opcode = "SHADOWHEIGHT", len = 2},
    [33] = {opcode = "SHADOWPOS", len = 3},
    [90] = {opcode = "SHADOW_CAST", len = 2},
    [86] = {opcode = "SHADOW_RANGE", len = 1},
    [100] = {opcode = "SHIMMER", len = 3},
    [104] = {opcode = "STAGE_LIGHT", len = 3},
    [6] = {opcode = "TARGET", len = 7},
    [84] = {opcode = "TARGET_FLAG", len = 1},
    [58] = {opcode = "TARGET_FLYING_TIME", len = 1},
    [1] = {opcode = "TIME", len = 1},
    [53] = {opcode = "TONE_TRANS", len = 6},
    [99] = {opcode = "TOON", len = 3},
    [69] = {opcode = "WIND", len = 3}
}

local function readInt32(file, offset)
    file:seek("set", offset)
    local data = file:read(4)
    local u = ffi.new("int32_union")
    ffi.copy(u.bytes, data)
    return u.i32
end

local CURRENT_TIME = 0

local opc, len, params
function processFile(filename, fmt)
    local fmt = fmt or "ft"
    local chart = {}
    local file = io.open(   love.filesystem.getSource() .. "/" .. filename, "rb")
    if not file then
        error("Failed to open file")
    end
    
    local commands = ""
    local errors = false
    local fileSize = file:seek("end")
    file:seek("set", 0)

    local i = 0
    while i < fileSize do
        local num = readInt32(file, i)
        if i == 0 then            
            thisdb = paramCounts
            if not (fmt == 'pd1' or fmt == 'pd2') then
                i = i + 4
                goto skip
            end
        end

        ::skip::

        if not thisdb[num] then
            errors = true
            i = i + 4
            goto skip1
        end

        -- lua is stewpid and crashes if these are local here
        opc = thisdb[num].opcode
        len = thisdb[num].len
        params = {}

        for j = 1, len do
            i = i + 4
            params[j] = readInt32(file, i)
        end

        if opc == "TIME" then
            CURRENT_TIME = params[1]
            if not DELAY then DELAY = CURRENT_TIME end
        elseif opc == "TARGET" then
            table.insert(chart, {
                type = "TARGET",
                params = params,
                time = CURRENT_TIME
            })
        elseif opc == "BAR_TIME_SET" then
            table.insert(chart, {
                type = "BAR_TIME_SET",
                params = params,
                time = CURRENT_TIME
            })
        elseif opc == "TARGET_FLYING_TIME" then
            table.insert(chart, {
                type = "TARGET_FLYING_TIME",
                params = params,
                time = CURRENT_TIME
            })
        end

        ::skip1::

        i = i + 4
    end

    file:close()

    if errors then
        print("warning: Unknown opcodes were found.\nThe file may be corrupt")
    end

    table.sort(chart, function(a, b)
        return a.time < b.time
    end)

    -- look for notes with same time, if found, set params[12] to true
    for i = 1, #chart do
        if chart[i].type == "TARGET" then
            for j = i + 1, #chart do
                if chart[j].type == "TARGET" and chart[j].time == chart[i].time then
                    chart[i].params[12] = true
                    chart[j].params[12] = true
                end
            end
        end
    end

    return chart, commands
end

return handler
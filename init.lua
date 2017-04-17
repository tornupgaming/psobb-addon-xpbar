-- Constants
local _PlayerOneTotalExpPointer = 0x068E5198

local _MaxLevels = 200
local _ExperienceChart = {
    0, 50, 200, 450, 800, 1250, 1800, 2450, 3200, 4050,
    5000, 6050, 7200, 8450, 9848, 11427, 13252, 15364, 17785, 20539,
    23644, 27118, 30979, 35245, 39924, 45022, 50548, 56515, 62935, 69816,
    77165, 84993, 93309, 102126, 111455, 121310, 131698, 142625, 154103, 166145,
    178762, 191962, 205756, 220153, 235166, 250807, 267086, 284012, 301595, 319847,
   
    338779, 358404, 378730, 399766, 421524, 444016, 467249, 491238, 515991, 541513,
    567815, 594908, 622800, 651502, 681023, 711375, 742566, 774604, 807502, 841271,
    875920, 911460, 947904, 985259, 1023533, 1062737, 1102882, 1143980, 1186040, 1229071,
    1273081, 1318092, 1364125, 1411201, 1459348, 1508599, 1558983, 1610536, 1663300, 1717321,
    1772647, 1829330, 1887428, 1947004, 2008126, 2070867, 2135310, 2201539, 2269648, 2339735,

    2411903, 2488164, 2568714, 2653755, 2743485, 2838105, 2937820, 3042926, 3153725, 3270523,
    3393621, 3523317, 3659910, 3803697, 3954983, 4114067, 4281251, 4456936, 4641520, 4835405,
    5038992, 5252677, 5476560, 5710739, 5955316, 6210392, 6476064, 6752432, 7039597, 7337658,
    7646717, 7966876, 8298232, 8640881, 8994927, 9360472, 9737616, 10126458, 10527095, 10939630,
    11364163, 11800795, 12249627, 12710761, 13184299, 13670344, 14168994, 14680346, 15204498, 15741551,

    16291604, 16854759, 17431119, 18020783, 18623854, 19240432, 19870618, 20514614, 21172626, 21844850,
    22531485, 23232732, 23948794, 24679868, 25426153, 26187854, 26965277, 27758726, 28568599, 29395299,
    30239347, 31101333, 31981946, 32881910, 33802211, 34743869, 35708107, 36696348, 37710175, 38751371,
    39821758, 40925323, 42068048, 43257823, 44504634, 45820378, 47219013, 48716731, 50331355, 52082887,
    53992896, 56085071, 58386099, 60923945, 63728621, 66837114, 70289303, 74132060, 78415384, 83227800
}

-- Should really get pointer location but finding it is proving
-- to be an absolute arse. Hacky / inefficient but it works ¯\_(ツ)_/¯
function GetCurrentLevel(currentExperience)
    for i=1, _MaxLevels do
        local levelExp = _ExperienceChart[i]
        local nextExp = _ExperienceChart[i+1]
        if currentExperience >= levelExp and currentExperience < nextExp then
            return i
        end
    end
    return _MaxLevels
end

-- Init
local on_init = function()
    return {
        name = "ExperienceBar",
        version = "1.0",
        author = "tornupgaming"
    }
end

-- Drawing
local on_present = function()

    -- Grab values from memory
    local totalExperience =  pso.read_u32(_PlayerOneTotalExpPointer)
    local currentLevel = GetCurrentLevel(totalExperience)

    -- If max level draw something and cancel out
    if currentLevel >= _MaxLevels then
        imgui.Begin("Experience Bar")
        imgui.ProgressBar(1)
        imgui.Text("(Lvl ".. currentLevel .. ")")
        imgui.End()
        return
    end

    -- Do the calculations
    local currentLevelTotalExp = _ExperienceChart[currentLevel]
    local nextLevelTotalExp = _ExperienceChart[currentLevel+1]
    local expRequiredBetweenLevels = nextLevelTotalExp - currentLevelTotalExp
    local currentExpIntoLevel = totalExperience - currentLevelTotalExp
    local perc = (100.0 / expRequiredBetweenLevels) * currentExpIntoLevel

    -- Perform the drawing
    imgui.Begin("Experience Bar")
    imgui.ProgressBar(perc / 100)
    imgui.Text("(Lvl " .. currentLevel .. ") " .. currentExpIntoLevel .. " / " .. expRequiredBetweenLevels)
    imgui.End()
end

-- Input
local on_key_pressed = function()
end

local on_key_released = function()
end

-- Entry Point
pso.on_init(on_init)
pso.on_present(on_present)
pso.on_key_pressed(on_key_pressed)
pso.on_key_released(on_key_released)

-- Exports for other modules
return {
    init = on_init,
    present = on_present,
    key_pressed = on_key_pressed
}
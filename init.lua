-- Constants
local _PlayerArray = 0x00A94254
local _PlayerMyIndex = 0x00A9C4F4
local _PLTPointer = 0x00A94878


local imguiProgressBar = function(progress, r, g, b, a)
    r = r or 0.90
    g = g or 0.70
    b = b or 0.00
    a = a or 1.00

    if progress == nil then
        imgui.Text("imguiProgressBar() Invalid progress")
        return
    end

    imgui.PushStyleColor("PlotHistogram", r, g, b, a)
    imgui.ProgressBar(progress)
    imgui.PopStyleColor()
end

local DrawStuff = function()
    local myIndex = pso.read_u32(_PlayerMyIndex)
    local myAddress = pso.read_u32(_PlayerArray + 4 * myIndex)
    local pltData = pso.read_u32(_PLTPointer)

    -- Do the thing only if the pointer is not null
    if myAddress == 0 then
        imgui.Text("Player data not found")
    elseif pltData == 0 then
        imgui.Text("PLT data not found")
    else
        local myClass = pso.read_u8(myAddress + 0x961)
        local myLevel = pso.read_u32(myAddress + 0xE44)
        local myExp = pso.read_u32(myAddress + 0xE48)

        local pltLevels = pso.read_u32(pltData)
        local pltClass = pso.read_u32(pltLevels + 4 * myClass)

        local thisMaxLevelExp = pso.read_u32(pltClass + 0x0C * myLevel + 0x08)
        local nextMaxLevelexp

        if myLevel < 199 then
            nextMaxLevelexp = pso.read_u32(pltClass + 0x0C * (myLevel + 1) + 0x08)
        else
            nextMaxLevelexp = thisMaxLevelExp
        end

        local thisLevelExp = myExp - thisMaxLevelExp
        local nextLevelexp = nextMaxLevelexp - thisMaxLevelExp
        local levelProgress = 1
        if nextLevelexp ~= 0 then
            levelProgress = thisLevelExp / nextLevelexp
        end

        imguiProgressBar(levelProgress, 0.0, 0.7, 1.0, 1.0)
        imgui.Text(string.format("Lv %i %i/%i", myLevel + 1, thisLevelExp, nextLevelexp))
    end
end

-- Drawing
local function present()
    imgui.Begin("Experience Bar")
    DrawStuff();
    imgui.End()
end

-- Init
local function init()
    return
    {
        name = "Experience Bar",
        version = "1.2",
        author = "tornupgaming",
        description = "Work in progress",
        present = present,
    }
end

-- Exports for other modules
return
{
    __addon =
    {
        init = init
    }
}

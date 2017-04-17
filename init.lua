-- Constants
local _PlayerArray = 0x00A94254
local _PlayerMyIndex = 0x00A9C4F4
local _PLTPointer = 0x00A94878

-- Init
local on_init = function()
    return {
        name = "ExperienceBar",
        version = "1.1",
        author = "tornupgaming"
    }
end

local DrawStuff = function()
    myIndex = pso.read_u32(_PlayerMyIndex)
    myAddress = pso.read_u32(_PlayerArray + 4 * myIndex)
    pltData = pso.read_u32(_PLTPointer)

    -- Do the thing only if the pointer is not null
    if myAddress == 0 then
        imgui.Text("Player data not found")
    elseif pltData == 0 then
        imgui.Text("PLT data not found")
    else
        myClass = pso.read_u8(myAddress + 0x961)
        myLevel = pso.read_u32(myAddress + 0xE44)
        myExp = pso.read_u32(myAddress + 0xE48)

        pltLevels = pso.read_u32(pltData)
        pltClass = pso.read_u32(pltLevels + 4 * myClass)
        
        thisMaxLevelExp = pso.read_u32(pltClass + 0x0C * myLevel + 0x08)
        if myLevel < 199 then
            nextMaxLevelexp = pso.read_u32(pltClass + 0x0C * (myLevel + 1) + 0x08)
        else
            nextMaxLevelexp = thisMaxLevelExp
        end

        thisLevelExp = myExp - thisMaxLevelExp
        nextLevelexp = nextMaxLevelexp - thisMaxLevelExp
        levelProgress = 1
        if nextLevelexp ~= 0 then
            levelProgress = thisLevelExp / nextLevelexp
        end

        imgui.ProgressBar(levelProgress)
        imgui.Text(string.format("Lv %i %i/%i", myLevel + 1, thisLevelExp, nextLevelexp))
    end
end

-- Drawing
local on_present = function()
    imgui.Begin("Experience Bar")
    DrawStuff();
    imgui.End()
end

-- Entry Point
pso.on_init(on_init)
pso.on_present(on_present)

-- Exports for other modules
return {
    init = on_init
}
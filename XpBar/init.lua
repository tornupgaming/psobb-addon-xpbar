-- Imports
local core_mainmenu = require("core_mainmenu")
local cfg = require("XpBar.configuration")
-- TODO move to options
local optionsLoaded, options = pcall(require, "XpBar.options")

local optionsFileName = "addons/XpBar/options.lua"

-- Constants
local _PlayerArray = 0x00A94254
local _PlayerMyIndex = 0x00A9C4F4
local _PLTPointer = 0x00A94878

if optionsLoaded then
    -- If options loaded, make sure we have all those we need
    options.configurationEnableWindow = options.configurationEnableWindow == nil and true or options.configurationEnableWindow
    options.enable = options.enable == nil and true or options.enable
    options.xpEnableWindow = options.xpEnableWindow == nil and true or options.xpEnableWindow
    options.xpNoTitleBar = options.xpNoTitleBar or ""
    options.xpNoResize = options.xpNoResize or ""
    options.xpEnableInfoText = options.xpEnableInfoText == nil and true or options.xpEnableInfoText
    options.xpTransparent = options.xpTransparent == nil and true or options.xpTransparent
else
    options = 
    {
        configurationEnableWindow = true,
        enable = true,
        xpEnableWindow = true,
        xpNoTitleBar = "",
        xpNoResize = "",
        xpEnableInfoText = true,
        xpTransparent = false
    }
end

local function SaveOptions(options)
    local file = io.open(optionsFileName, "w")
    if file ~= nil then
        io.output(file)

        io.write("return {\n")
        io.write(string.format("    configurationEnableWindow = %s,\n", tostring(options.configurationEnableWindow)))
        io.write(string.format("    enable = %s,\n", tostring(options.enable)))
        io.write("\n")
        io.write(string.format("    xpEnableWindow = %s,\n", tostring(options.xpEnableWindow)))
        io.write(string.format("    xpNoTitleBar = \"%s\",\n", options.xpNoTitleBar))
        io.write(string.format("    xpNoResize = \"%s\",\n", options.xpNoResize))
        io.write(string.format("    xpEnableInfoText = %s\n", tostring(options.xpEnableInfoText)))
        io.write(string.format("    xpTransparent = %s\n", tostring(options.xpTransparent)))
        io.write("}\n")

        io.close(file)
    end
end

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
        if options.xpEnableInfoText then
            imgui.Text(string.format("Lv %i %i/%i", myLevel + 1, thisLevelExp, nextLevelexp))
        end
    end
end

-- Drawing
local function present()

-- If the addon has never been used, open the config window
    -- and disable the config window setting
    if options.configurationEnableWindow then
        ConfigurationWindow.open = true
        options.configurationEnableWindow = false
    end

    ConfigurationWindow.Update()
    if ConfigurationWindow.changed then
        ConfigurationWindow.changed = false
        SaveOptions(options)
    end

    -- Global enable here to let the configuration window work
    if options.enable == false then
        return
    end

    if options.xpTransparent then
        imgui.PushStyleColor("WindowBg", 0, 0, 0, 0)
    end

    if options.xpEnableWindow then
        imgui.Begin("Experience Bar", nil, { options.xpNoTitleBar, options.xpNoResize })
        DrawStuff();
        imgui.End()
    end

    if options.xpTransparent then
        imgui.PopStyleColor(1)
    end
end

-- Init
local function init()
    ConfigurationWindow = cfg.ConfigurationWindow(options)

    local function mainMenuButtonHandler()
        ConfigurationWindow.open = not ConfigurationWindow.open
    end

    core_mainmenu.add_button("XP Bar", mainMenuButtonHandler)


    return
    {
        name = "Experience Bar",
        version = "1.4",
        author = "tornupgaming",
        description = "Displays your current character experience in a handy visual bar.",
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

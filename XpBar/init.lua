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

-- Helpers in solylib
local function _getMenuState()
    local offsets = {
        0x00A98478,
        0x00000010,
        0x0000001E,
    }
    local address = 0
    local value = -1
    local bad_read = false
    for k, v in pairs(offsets) do
        if address ~= -1 then
            address = pso.read_u32(address + v)
            if address == 0 then
                address = -1
            end
        end
    end
    if address ~= -1 then
        value = bit.band(address, 0xFFFF)
    end
    return value
end
local function IsMenuOpen()
    local menuOpen = 0x43
    local menuState = _getMenuState()
    return menuState == menuOpen
end
local function IsSymbolChatOpen()
    local wordSelectOpen = 0x40
    local menuState = _getMenuState()
    return menuState == wordSelectOpen
end
local function IsMenuUnavailable()
    local menuState = _getMenuState()
    return menuState == -1
end
local function NotNilOrDefault(value, default)
    if value == nil then
        return default
    else
        return value
    end
end
-- End of helpers in solylib

if optionsLoaded then
    -- If options loaded, make sure we have all those we need
    options.configurationEnableWindow = NotNilOrDefault(options.configurationEnableWindow, true)
    options.enable                    = NotNilOrDefault(options.enable, true)
    options.xpEnableWindow            = NotNilOrDefault(options.xpEnableWindow, true)
    options.xpHideWhenMenu            = NotNilOrDefault(options.xpHideWhenMenu, true)
    options.xpHideWhenSymbolChat      = NotNilOrDefault(options.xpHideWhenSymbolChat, true)
    options.xpHideWhenMenuUnavailable = NotNilOrDefault(options.xpHideWhenMenuUnavailable, true)
    options.xpShowDefaultNotError     = NotNilOrDefault(options.xpShowDefaultNotError, false)
    options.xpNoTitleBar              = NotNilOrDefault(options.xpNoTitleBar, "")
    options.xpNoResize                = NotNilOrDefault(options.xpNoResize, "")
    options.xpNoMove                  = NotNilOrDefault(options.xpNoMove, "")
    options.xpTransparent             = NotNilOrDefault(options.xpTransparent, false)
    options.xpEnableInfoLevel         = NotNilOrDefault(options.xpEnableInfoLevel, true)
    options.xpEnableInfoTotal         = NotNilOrDefault(options.xpEnableInfoTotal, true)
    options.xpEnableInfoTNL           = NotNilOrDefault(options.xpEnableInfoTNL, true)
    options.xpBarNoOverlay            = NotNilOrDefault(options.xpBarNoOverlay, false)
    options.xpBarColor                = NotNilOrDefault(options.xpBarColor, 0xFFE6B300)
    options.xpBarX                    = NotNilOrDefault(options.xpBarX, 50)
    options.xpBarY                    = NotNilOrDefault(options.xpBarY, 50)
    options.xpBarWidth                = NotNilOrDefault(options.xpBarWidth, -1)
    options.xpBarHeight               = NotNilOrDefault(options.xpBarHeight, 0)
else
    options =
    {
        configurationEnableWindow = true,
        enable = true,
        xpEnableWindow = true,
        xpHideWhenMenu = false,
        xpHideWhenSymbolChat = false,
        xpHideWhenMenuUnavailable = false,
        xpShowDefaultNotError = false,
        xpNoTitleBar = "",
        xpNoResize = "",
        xpNoMove = "",
        xpTransparent = false,
        xpEnableInfoLevel = true,
        xpEnableInfoTotal = true,
        xpEnableInfoTNL = true,
        xpBarNoOverlay = false,
        xpBarColor = 0xFFE6B300,
        xpBarX = 50,
        xpBarY = 50,
        xpBarWidth = -1,
        xpBarHeight = 0,
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
        io.write(string.format("    xpHideWhenMenu = %s,\n", tostring(options.xpHideWhenMenu)))
        io.write(string.format("    xpHideWhenSymbolChat = %s,\n", tostring(options.xpHideWhenSymbolChat)))
        io.write(string.format("    xpHideWhenMenuUnavailable = %s,\n", tostring(options.xpHideWhenMenuUnavailable)))
        io.write(string.format("    xpShowDefaultNotError = %s,\n", tostring(options.xpShowDefaultNotError)))
        io.write(string.format("    xpNoTitleBar = \"%s\",\n", options.xpNoTitleBar))
        io.write(string.format("    xpNoResize = \"%s\",\n", options.xpNoResize))
        io.write(string.format("    xpNoMove = \"%s\",\n", options.xpNoMove))
        io.write(string.format("    xpTransparent = %s,\n", tostring(options.xpTransparent)))
        io.write(string.format("    xpEnableInfoLevel = %s,\n", tostring(options.xpEnableInfoLevel)))
        io.write(string.format("    xpEnableInfoTotal = %s,\n", tostring(options.xpEnableInfoTotal)))
        io.write(string.format("    xpEnableInfoTNL = %s,\n", tostring(options.xpEnableInfoTNL)))
        io.write(string.format("    xpBarNoOverlay = %s,\n", tostring(options.xpBarNoOverlay)))
        io.write(string.format("    xpBarColor = 0x%08X,\n", options.xpBarColor))
        io.write(string.format("    xpBarX = %f,\n", options.xpBarX))
        io.write(string.format("    xpBarY = %f,\n", options.xpBarY))
        io.write(string.format("    xpBarWidth = %f,\n", options.xpBarWidth))
        io.write(string.format("    xpBarHeight = %f,\n", options.xpBarHeight))
        io.write("}\n")

        io.close(file)
    end
end

local function GetColorAsFloats(color)
    color = color or 0xFFFFFFFF

    local a = bit.band(bit.rshift(color, 24), 0xFF) / 255;
    local r = bit.band(bit.rshift(color, 16), 0xFF) / 255;
    local g = bit.band(bit.rshift(color, 8), 0xFF) / 255;
    local b = bit.band(color, 0xFF) / 255;

    return { r = r, g = g, b = b, a = a }
end

local imguiProgressBar = function(progress, color)
    color = color or 0xE6B300FF

    if progress == nil then
        imgui.Text("imguiProgressBar() Invalid progress")
        return
    end

    local overlay = nil
    if options.xpBarNoOverlay then
        overlay = ""
    end

    c = GetColorAsFloats(color)
    imgui.PushStyleColor("PlotHistogram", c.r, c.g, c.b, c.a)
    imgui.ProgressBar(progress, options.xpBarWidth, options.xpBarHeight, overlay)
    imgui.PopStyleColor()
end


-- Validate and render  the bar given the pre-determined values
local renderBarAndText = function(currentLevel, currentExp, expToNextLevel, progressAsFraction)

    imguiProgressBar(progressAsFraction, options.xpBarColor)

    if options.xpEnableInfoLevel then
        imgui.Text(string.format("Lv    : %i", currentLevel + 1))
    end

    if options.xpEnableInfoTotal then
        imgui.Text(string.format("Total : %i", currentExp))
    end

    if options.xpEnableInfoTNL then
        imgui.Text(string.format("TNL   : %i", expToNextLevel))
    end
end

local renderError = function(errorMsg)
    if (options.xpShowDefaultNotError == false) then
        imgui.Text(errorMsg)
    else
        renderBarAndText(0, 0, 50, 0)
    end
end


local DrawStuff = function()
    local currentPlayerIndex = pso.read_u32(_PlayerMyIndex)
    local characterMemAddress = pso.read_u32(_PlayerArray + 4 * currentPlayerIndex)
    local pltData = pso.read_u32(_PLTPointer)

    -- Check the player has selected a character
    if characterMemAddress == 0 then 
        renderError("Player data not found")
        return
    end

    -- Check that our player data is available
    if pltData == 0 then 
        renderError("PLT data not found")
        return
    end

    local myClass = pso.read_u8(characterMemAddress + 0x961)
    local charCurrentLevel = pso.read_u32(characterMemAddress + 0xE44)
    local charTotalExp = pso.read_u32(characterMemAddress + 0xE48)

    local pltLevels = pso.read_u32(pltData)
    local pltClass = pso.read_u32(pltLevels + 4 * myClass)

    local thisMaxLevelExp = pso.read_u32(pltClass + 0x0C * charCurrentLevel + 0x08)
    local nextMaxLevelexp

    if charCurrentLevel < 199 then
        nextMaxLevelexp = pso.read_u32(pltClass + 0x0C * (charCurrentLevel + 1) + 0x08)
    else
        nextMaxLevelexp = thisMaxLevelExp
    end

    local thisLevelExp = charTotalExp - thisMaxLevelExp
    local nextLevelexp = nextMaxLevelexp - thisMaxLevelExp
    local expToNextLevel = nextMaxLevelexp - charTotalExp
    local progressAsFraction = 1
    if nextLevelexp ~= 0 then
        progressAsFraction = math.floor(100 * (thisLevelExp / nextLevelexp)) / 100
    end

    renderBarAndText(charCurrentLevel, charTotalExp, expToNextLevel, progressAsFraction)
end

-- Drawing
local function present()
    local changedOptions = false
-- If the addon has never been used, open the config window
    -- and disable the config window setting
    if options.configurationEnableWindow then
        ConfigurationWindow.open = true
        options.configurationEnableWindow = false
    end

    ConfigurationWindow.Update()
    if ConfigurationWindow.changed then
        changedOptions = true
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

    if (options.xpEnableWindow)
        and (options.xpHideWhenMenu == false or IsMenuOpen() == false)
        and (options.xpHideWhenSymbolChat == false or IsSymbolChatOpen() == false)
        and (options.xpHideWhenMenuUnavailable == false or IsMenuUnavailable() == false)
    then
        if changedOptions == true then
            changedOptions = false
            imgui.SetNextWindowPos(options.xpBarX, options.xpBarY, "Always");
        end
        imgui.Begin("Experience Bar", nil, { options.xpNoTitleBar, options.xpNoResize, options.xpNoMove, "AlwaysAutoResize" })
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

local function PresentColorEditor(label, col, col_d)
    local changed = false
    local i =
    {
        bit.band(bit.rshift(col, 16), 0xFF),
        bit.band(bit.rshift(col, 8), 0xFF),
        bit.band(col, 0xFF),
        bit.band(bit.rshift(col, 24), 0xFF),
    }

    local ids = { "##X", "##Y", "##Z", "##W" }
    local fmt = { "R:%3.0f", "G:%3.0f", "B:%3.0f", "A:%3.0f" }

    imgui.BeginGroup()
    imgui.PushID(label)

    imgui.PushItemWidth(50)
    for n = 1, 4, 1 do
        local changedDragInt = false
        if n ~= 1 then
            imgui.SameLine(0, 5)
        end

        changedDragInt, i[n] = imgui.DragInt(ids[n], i[n], 1.0, 0, 255, fmt[n])
    end
    imgui.PopItemWidth()

    imgui.SameLine(0, 5)
    imgui.ColorButton(i[1] / 255, i[2] / 255, i[3] / 255, 1.0)
    if imgui.IsItemHovered() then
        imgui.SetTooltip(
            string.format(
                "Color:\n#%02X%02X%02X%02X",
                i[1], i[2], i[3], i[4]
            )
        )
    end

    imgui.SameLine(0, 5)
    imgui.Text(label)

    col = bit.lshift(i[4], 24) + bit.lshift(i[1], 16) +  bit.lshift(i[2], 8) +  i[3]

    imgui.SameLine(0, 5)
    if imgui.Button("Reset") then
        col = col_d
    end

    imgui.PopID()
    imgui.EndGroup()

    return col
end

local function ConfigurationWindow(configuration)
    local this =
    {
        title = "Experience Bar - Configuration",
        fontScale = 1.0,
        open = false,
        changed = false,
    }

    local _configuration = configuration

    local _showWindowSettings = function()
        local success

        if imgui.Checkbox("Enable", _configuration.xpEnableWindow) then
            _configuration.xpEnableWindow = not _configuration.xpEnableWindow
            this.changed = true
        end

        if imgui.Checkbox("Hide when menus are open", _configuration.xpHideWhenMenu) then
            _configuration.xpHideWhenMenu = not _configuration.xpHideWhenMenu
            this.changed = true
        end
        if imgui.Checkbox("Hide when symbol chat/word select is open", _configuration.xpHideWhenSymbolChat) then
            _configuration.xpHideWhenSymbolChat = not _configuration.xpHideWhenSymbolChat
            this.changed = true
        end
        if imgui.Checkbox("Hide when the menu is unavailable", _configuration.xpHideWhenMenuUnavailable) then
            _configuration.xpHideWhenMenuUnavailable = not _configuration.xpHideWhenMenuUnavailable
            this.changed = true
        end

        if imgui.Checkbox("Show default instead of error", _configuration.xpShowDefaultNotError) then
            _configuration.xpShowDefaultNotError = not _configuration.xpShowDefaultNotError
            this.changed = true
        end

        if imgui.Checkbox("No title bar", _configuration.xpNoTitleBar == "NoTitleBar") then
            if _configuration.xpNoTitleBar == "NoTitleBar" then
                _configuration.xpNoTitleBar = ""
            else
                _configuration.xpNoTitleBar = "NoTitleBar"
            end
            this.changed = true
        end

        if imgui.Checkbox("No resize", _configuration.xpNoResize == "NoResize") then
            if _configuration.xpNoResize == "NoResize" then
                _configuration.xpNoResize = ""
            else
                _configuration.xpNoResize = "NoResize"
            end
            this.changed = true
        end
        if imgui.Checkbox("No Move", _configuration.xpNoMove == "NoMove") then
            if _configuration.xpNoMove == "NoMove" then
                _configuration.xpNoMove = ""
            else
                _configuration.xpNoMove = "NoMove"
            end
            this.changed = true
        end

        if imgui.Checkbox("Transparent Background", _configuration.xpTransparent) then
            _configuration.xpTransparent = not _configuration.xpTransparent
            this.changed = true
        end

        if imgui.Checkbox("Enable Info Level", _configuration.xpEnableInfoLevel) then
            _configuration.xpEnableInfoLevel = not _configuration.xpEnableInfoLevel
            this.changed = true
        end
        if imgui.Checkbox("Enable Info Total Exp", _configuration.xpEnableInfoTotal) then
            _configuration.xpEnableInfoTotal = not _configuration.xpEnableInfoTotal
            this.changed = true
        end
        if imgui.Checkbox("Enable Info To Next Level Exp", _configuration.xpEnableInfoTNL) then
            _configuration.xpEnableInfoTNL = not _configuration.xpEnableInfoTNL
            this.changed = true
        end

        if imgui.Checkbox("XP bar no overlay", _configuration.xpBarNoOverlay) then
            _configuration.xpBarNoOverlay = not _configuration.xpBarNoOverlay
            this.changed = true
        end

        local oldColor = _configuration.xpBarColor
        _configuration.xpBarColor = PresentColorEditor("XP bar color", _configuration.xpBarColor, 0xFFE6B300)
        if oldColor ~= _configuration.xpBarColor then
            this.changed = true
        end

        imgui.PushItemWidth(110)
        changedDragInt, _configuration.xpBarX = imgui.DragInt("##X", _configuration.xpBarX, 1.0, 0, 0, "X: %4.0f")
        if changedDragInt then
            this.changed = true
        end

        imgui.SameLine(0, 5)
        changedDragInt, _configuration.xpBarY = imgui.DragInt("##Y", _configuration.xpBarY, 1.0, 0, 0, "Y: %4.0f")
        if changedDragInt then
            this.changed = true
        end

        changedDragInt, _configuration.xpBarWidth = imgui.DragInt("##W", _configuration.xpBarWidth, 1.0, -1, 1920, "Width: %4.0f")
        if changedDragInt then
            this.changed = true
        end

        imgui.SameLine(0, 5)
        changedDragInt, _configuration.xpBarHeight = imgui.DragInt("##H", _configuration.xpBarHeight, 1.0, 0, 1080, "Height: %4.0f")
        if changedDragInt then
            this.changed = true
        end
        imgui.PopItemWidth()
    end

    this.Update = function()
        if this.open == false then
            return
        end

        local success

        imgui.SetNextWindowSize(500, 400, 'FirstUseEver')
        success, this.open = imgui.Begin(this.title, this.open)
        imgui.SetWindowFontScale(this.fontScale)

        _showWindowSettings()

        imgui.End()
    end

    return this
end

return
{
    ConfigurationWindow = ConfigurationWindow,
}

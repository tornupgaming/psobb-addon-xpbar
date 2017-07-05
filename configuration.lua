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

        if imgui.Checkbox("Enable Info Text", _configuration.xpEnableInfoText) then
            _configuration.xpEnableInfoText = not _configuration.xpEnableInfoText
            this.changed = true
        end
    
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

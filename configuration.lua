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
        
        if imgui.Checkbox("Enable", _configuration.mhpEnableWindow) then
            _configuration.mhpEnableWindow = not _configuration.mhpEnableWindow
            this.changed = true
        end
        
        if imgui.Checkbox("No title bar", _configuration.mhpNoTitleBar == "NoTitleBar") then
            if _configuration.mhpNoTitleBar == "NoTitleBar" then
                _configuration.mhpNoTitleBar = ""
            else
                _configuration.mhpNoTitleBar = "NoTitleBar"
            end
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

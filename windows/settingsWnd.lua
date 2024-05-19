local ImGui = require('ImGui')
local mq = require('mq')
local settingsWnd = {}

settingsWnd.characterList = {
    items = {},
    selected = 1
}


function settingsWnd.GetSections()
    for settingName, value in pairs(Settings) do
        for character, settingValue in pairs(Settings[settingName]) do
            local nameFound = false
            for index, value in ipairs(settingsWnd.characterList.items) do
                if not nameFound then
                    if value == character then
                        nameFound = true
                    end
                end
            end
            if not nameFound then
                table.insert(settingsWnd.characterList.items, character)
            end
        end
    end
end

function settingsWnd.sectionHandler(section)
    ImGui.SetCursorPos(10, 60)

    if ImGui.BeginListBox("", ImVec2(150, 350)) then
        for i, item in pairs(settingsWnd.characterList.items) do
            local _, clicked = ImGui.Selectable(item, settingsWnd.characterList.selected == i)
            ImGui.Separator()
            if clicked then settingsWnd.characterList.selected = i end
        end
    end
    ImGui.EndListBox()
end

function settingsWnd.DrawSettingsWindow()
    local settingsPath = 'mimicSettings.lua'
    ImGui.SetWindowSize('Settings', 500, 500,ImGuiCond.FirstUseEver)
    settingsWnd.GetSections()
    settingsWnd.sectionHandler()

    ImGui.SetCursorPos(170, 60)
    local section = settingsWnd.characterList.items[settingsWnd.characterList.selected]
    for settingName, value in pairs(Settings) do
        for toonName, settingValue in pairs(Settings[settingName]) do
            if toonName == section then
                ImGui.SetCursorPos(170, ImGui.GetCursorPosY())
                if not string.find(settingName, "Show") then
                    if type(settingValue) == 'boolean' then
                        ImGui.Text(settingName)
                        ImGui.SameLine()
                        ImGui.SetCursorPosX(350)
                        local settingValue, clicked = ImGui.Checkbox("##" .. settingName, settingValue)
                        local showName = settingName:gsub("Open", "Show")
                        if clicked then
                            Settings[settingName][toonName] = not Settings[settingName][toonName]
                            Settings[showName][toonName] = not Settings[showName][toonName]
                            mq.pickle('PMSettings.lua', Settings)
                            local newFileData, error = loadfile(mq.configDir .. '/' .. 'PMSettings.lua')
                            if newFileData then
                                Settings = newFileData()
                            end
                        end
                    end
                end
            end
        end
    end
end

return settingsWnd

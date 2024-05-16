local mq = require('mq')
local imgui = require('ImGui')
local settingsWnd = require('windows/settingsWnd')
local dataHandler = require('dataHandler')
local spellbarWnd = require('windows/spellbarWnd')
local groupWindow = require('windows/groupWindow')
local targetWindow= require('windows/targetWindow')
local buffWindow  = require('windows/buffWindow')
local xtargetWindow = require('windows/xtargetWindow')
local gui = {}

local window_flags = 0
local no_titlebar = true
local no_scrollbar = true
local no_resize = true
if no_titlebar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoTitleBar) end
if no_scrollbar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoScrollbar) end
if no_resize then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoResize) end

gui.showGui, gui.openGui = true, true



local typeHandlers = {
    Spellbar = spellbarWnd.DrawSpellbar,
    Group = groupWindow.DrawGroupWindow,
    Xtar = xtargetWindow.DrawMimicXTargetWindow,
    Target = targetWindow.DrawTargetWindow,
    --Pet = mimicPet.DrawPetWindow,
    --["Control Dash"] = mimicControlDash.DrawControlDash,
    Buffs = buffWindow.DrawBuffWindow,
    --Loadout = mimicLoadoutWindow.DrawMimicLoadoutWindow
}

local function OpenAllInstances(open, show, name, type, windowflags)
    for charName, isOpen in pairs(open) do
        if open[charName] then
            open[charName], show[charName] = ImGui.Begin(name .. '-' .. charName, show[charName], windowflags)
            if show[charName] then
                local handler = typeHandlers[type]
                if handler then
                    handler(charName, dataHandler.GetData(charName))
                end
            end
            ImGui.End()
        end
    end
end
local function getFilePath(fileName)
    local filePath = debug.getinfo(1, 'S').short_src
    local path = filePath:match("(.+\\)") .. fileName
    return path
end
local PMIconFile = getFilePath('PM.png')
local PMIconTexture = mq.CreateTexture(PMIconFile)

local function drawPMButton()
    local draw_list = ImGui.GetWindowDrawList()
    ImGui.SetWindowSize(64, 64)
    ImGui.SetCursorPos(0,0)
    local bgPos = ImGui.GetWindowPosVec()
    draw_list:AddImage(PMIconTexture:GetTextureID(), bgPos, ImVec2(bgPos.x + 64, bgPos.y + 64))

    local pmButton = ImGui.InvisibleButton('Settings', 60, 60)
    if pmButton then
        OpenSettings = not OpenSettings
    end
end


function gui.guiLoop()
    OpenAllInstances(Settings.OpenSpellbar, Settings.ShowSpellbar, "Spellbar", "Spellbar", window_flags)
    OpenAllInstances(Settings.OpenGroup, Settings.ShowGroup, "Group", "Group", window_flags)
    OpenAllInstances(Settings.OpenXTarget, Settings.ShowXTarget, "XTarget", 'Xtar', window_flags)
    OpenAllInstances(Settings.OpenTarget, Settings.ShowTarget, "Target", 'Target', window_flags)
    OpenAllInstances(Settings.OpenPet, Settings.ShowPet, "Mimic Pet", "Pet", window_flags)
    OpenAllInstances(Settings.OpenDash, Settings.ShowDash, "Control Dash", "Control Dash", window_flags)
    OpenAllInstances(Settings.OpenBuffs, Settings.ShowBuffs, "Buffs", "Buffs",
        bit32.bor(ImGuiWindowFlags.NoTitleBar))
    OpenAllInstances(Settings.OpenLoadout, Settings.ShowLoadout, "Loadout", "Loadout", window_flags)

    if OpenSettings then
        OpenSettings, ShowSettings = ImGui.Begin('Settings', OpenSettings)
        if ShowSettings then
            settingsWnd.DrawSettingsWindow()
        end
        ImGui.End()
    end
    if gui.openGui then
        gui.openGui, gui.showGui = ImGui.Begin('PMButton', gui.showGui, window_flags)
        if gui.showGui then
            drawPMButton()
        end
        ImGui.End()
    end
end

return gui

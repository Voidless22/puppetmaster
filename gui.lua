local mq = require('mq')
local imgui = require('ImGui')
local settingsWnd = require('windows/settingsWnd')
local dataHandler = require('dataHandler')
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
    --Spellbar = mimicSpellbar.DrawSpellbar,
    --Group = mimicGroup.DrawMimicGroupWindow,
    --Xtar = mimicXTarget.DrawMimicXTargetWindow,
    --Target = mimicTarget.DrawMimicTargetWindow,
    --Pet = mimicPet.DrawPetWindow,
    --["Control Dash"] = mimicControlDash.DrawControlDash,
    --Buffs = mimicBuffWindow.DrawMimicBuffWindow,
    --Loadout = mimicLoadoutWindow.DrawMimicLoadoutWindow
}

local function OpenAllInstances(open, show, name, type, windowflags)
    for charName, isOpen in pairs(open) do
        if open[charName] then
            open[charName], show[charName] = ImGui.Begin(name .. charName, show[charName], windowflags)
            if show[charName] then
                local handler = typeHandlers[type]
                if handler then
                    handler(charName, dataHandler.boxes[charName])
                end
            end
            ImGui.End()
        end
    end
end

 
function gui.guiLoop()
    OpenAllInstances(Settings.OpenSpellbar, Settings.ShowSpellbar, "Mimic Bar", "Spellbar", window_flags)
    OpenAllInstances(Settings.OpenGroup, Settings.ShowGroupWindow, "Mimic Group", "Group", window_flags)
    OpenAllInstances(Settings.OpenXTarget, Settings.ShowXTarget, "Mimic XTarget", 'Xtar', window_flags)
    OpenAllInstances(Settings.OpenTarget, Settings.ShowTarget, "Mimic Target", 'Target', window_flags)
    OpenAllInstances(Settings.OpenPet, Settings.ShowPet, "Mimic Pet", "Pet", window_flags)
    OpenAllInstances(Settings.OpenDash, Settings.ShowDash, "Control Dash", "Control Dash", window_flags)
    OpenAllInstances(Settings.OpenBuffs, Settings.ShowBuffs, "Mimic Buffs", "Buffs",
        bit32.bor(ImGuiWindowFlags.NoTitleBar))
    OpenAllInstances(Settings.OpenLoadout, Settings.ShowLoadout, "Loadout", "Loadout", window_flags)

    if OpenSettings then
        OpenSettings, ShowSettings = ImGui.Begin('Settings', OpenSettings)
        if ShowSettings then
            settingsWnd.DrawSettingsWindow()
        end
        ImGui.End()
    end
end

return gui

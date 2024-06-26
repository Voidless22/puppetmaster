local mq            = require('mq')
local imgui         = require('ImGui')
local settingsWnd   = require('windows/settingsWnd')
local dataHandler   = require('dataHandler')
local spellbarWnd   = require('windows/spellbarWnd')
local groupWindow   = require('windows/groupWindow')
local targetWindow  = require('windows/targetWindow')
local buffWindow    = require('windows/buffWindow')
local xtargetWindow = require('windows/xtargetWindow')
local petWindow     = require('windows.petWindow')
local loadoutWindow = require('windows/loadoutWindow')
local dashWindow    = require('windows.dashWindow')
local playerWindow  = require('windows/playerWindow')
local gui           = {}

local window_flags  = 0
local no_titlebar   = true
local no_scrollbar  = true
local no_resize     = false
if no_titlebar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoTitleBar) end
if no_scrollbar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoScrollbar) end
if no_resize then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoResize) end

gui.showGui, gui.openGui = true, true

gui.OpenSettings = false
gui.ShowSettings = false


local typeHandlers = {
    Spellbar = spellbarWnd.DrawSpellbar,
    Group = groupWindow.DrawGroupWindow,
    Xtar = xtargetWindow.DrawMimicXTargetWindow,
    Target = targetWindow.DrawTargetWindow,
    Pet = petWindow.DrawPetWindow,
    Dash = dashWindow.DrawControlDash,
    Buffs = buffWindow.DrawBuffWindow,
    Loadout = loadoutWindow.DrawLoadoutWindow,
    Player = playerWindow.DrawPlayerWindow
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
    local filePath = debug.getinfo(1,'S').short_src

    print(filePath)
    local path = filePath:gsub("gui.lua", fileName)

    print(path)
    return path
end
local PMIconFile = getFilePath('PM.png')
local PMIconTexture = mq.CreateTexture(PMIconFile)

local function drawPMButton()
    ImGui.SetWindowSize(72,72)
    ImGui.SetCursorPos(0, 0)
    if PMIconTexture then
      local PMButton = ImGui.ImageButton("Settings", PMIconTexture:GetTextureID(), PMIconTexture.size,ImVec2(0, 0), ImVec2(1, 1), ImVec4(0, 0, 0, 0), ImVec4(1, 1, 1, 1))
    
      if PMButton then
        print(PMIconTexture:GetTextureID())
        gui.OpenSettings = not gui.OpenSettings
      end
    end
end


function gui.guiLoop()
    OpenAllInstances(Settings.OpenSpellbar, Settings.ShowSpellbar, "Spellbar", "Spellbar", window_flags)
    OpenAllInstances(Settings.OpenGroup, Settings.ShowGroup, "Group", "Group", window_flags)
    OpenAllInstances(Settings.OpenXTarget, Settings.ShowXTarget, "XTarget", 'Xtar', window_flags)
    OpenAllInstances(Settings.OpenTarget, Settings.ShowTarget, "Target", 'Target', window_flags)
    OpenAllInstances(Settings.OpenPet, Settings.ShowPet, "Pet", "Pet", window_flags)
    OpenAllInstances(Settings.OpenDash, Settings.ShowDash, "Dash", "Dash", window_flags)
    OpenAllInstances(Settings.OpenBuffs, Settings.ShowBuffs, "Buffs", "Buffs",
        bit32.bor(ImGuiWindowFlags.NoTitleBar))
    OpenAllInstances(Settings.OpenLoadout, Settings.ShowLoadout, "Loadout", "Loadout", window_flags)
    OpenAllInstances(Settings.OpenPlayer, Settings.ShowPlayer, "Player", "Player", window_flags)

    if gui.OpenSettings then
        gui.OpenSettings, gui.ShowSettings = ImGui.Begin('Settings',  gui.OpenSettings)
        if gui.OpenSettings then
            settingsWnd.DrawSettingsWindow()
        end
        ImGui.End()
    end
    if gui.openGui then
        gui.openGui, gui.showGui = ImGui.Begin('PMButton', gui.showGui, bit32.bor(window_flags, ImGuiWindowFlags.NoResize))
        if gui.showGui and PMIconTexture then
            drawPMButton()
        end
        ImGui.End()
    end
end

return gui

local mq = require('mq')
local ImGui = require('ImGui')
local playerWnd = require('gui/playerWnd')
local groupWnd = require('gui/groupWnd')
local xtargetWnd = require('gui/xtargetWnd')
local targetWnd = require('gui/targetWnd')
local buffWnd = require('gui/buffWnd')
local msgHandler = require('msgHandler')
local Write   = require('knightlinc/Write')
local showPM, openPM = true, true
local gui = {}

local ShowWindows = {
    ShowMimicSpellBar = {},
    ShowMimicGroupWindow = {},
    ShowXTargetMimicWindow = {},
    ShowTargetMimicWindow = {},
    ShowMimicPetWindow = {},
    ShowMimicControlDash = {},
    ShowMimicBuffWindow = {},
    ShowMimicLoadoutWindow = {}
}

local Settings = {
    OpenSpellbarWnd = {},
    OpenGroupWnd = {},
    OpenXTargetWnd = {},
    OpenTargetWnd = {},
    --   OpenMimicPetWindow = {},
    --   OpenMimicControlDash = {},
    OpenBuffWnd = {},
    --OpenMimicLoadoutWindow = {}
}


-- Template: guiData[charName] = { Spellbar = {}, Spellbook = {}, Stats = {}, Group = {}, Target = {}, XTarget = {}, IsCasting = false }
gui.guiData = {}

-- Windows needed to be drawn:
-- Player Spellbar Buffs Target XTarget Group Pet
local typeHandlers = {
   -- Spellbar = playerWnd.DrawSpellbarWnd,
   -- Group = groupWnd.DrawGroupWnd,
    --Xtar = xtargetWnd.DrawMimicXTargetWindow,
    --Target = targetWnd.DrawMimicTargetWindow,
    -- Pet = mimicPet.DrawPetWindow,
    --   ["Control Dash"] = mimicControlDash.DrawControlDash,
    --Buffs = buffWnd.DrawMimicBuffWindow,
    -- Loadout = mimicLoadoutWindow.DrawMimicLoadoutWindow
}
local function OpenAllInstances(open, show, name, type, windowflags)
    for charName, isOpen in pairs(open) do
        if open[charName] then
            open[charName], show[charName] = ImGui.Begin(name .. charName, show[charName], windowflags)
            if show[charName] then
                local handler = typeHandlers[type]
                if handler then
                    handler(charName, gui.guiData[charName])
                end
            end
            ImGui.End()
        end
    end
end


function gui.updateGuiData(guiData)
    gui.guiData = guiData
    for boxName, boxData in pairs(msgHandler.boxes) do
        for index, value in pairs(Settings) do
            if value[boxName] == nil then
                value[boxName] = true
                Write.Debug('Defaulting missing setting for %s', boxName)
            end
        end
    end
end

function gui.guiLoop()

end

return gui

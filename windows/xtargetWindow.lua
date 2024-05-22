local mq = require('mq')
local imgui = require('ImGui')
local msgHandler = require('msgHandler')
local utils = require('utils')
local xtargetWindow = {}


function xtargetWindow.DrawMimicXTargetWindow(charName, charTable)
    ImGui.SetWindowSize("XTarget-" .. charName, 128, 256,ImGuiCond.FirstUseEver)
    local xtargetRatio = {}
    local xtargetButtons = {}
    local xtargetManaRatio = {}
    ImGui.Text("%s's XTarget", charName)
    if charTable.XTarget ~= nil then
        for currentXtarget = 1, #charTable.XTarget do
            if charTable.XTarget[currentXtarget] ~= 'Empty' and charTable.XTarget[currentXtarget] ~= 0 and charTable.XTarget[currentXtarget] ~= nil
                and mq.TLO.Spawn(charTable.XTarget[currentXtarget])() ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                xtargetRatio[currentXtarget] = mq.TLO.Spawn(charTable.XTarget[currentXtarget]).PctHPs() / 100 or 0
                xtargetManaRatio[currentXtarget] = mq.TLO.Spawn(charTable.XTarget[currentXtarget]).PctMana() / 100 or 0
                ImGui.Text(mq.TLO.Spawn(charTable.XTarget[currentXtarget]).CleanName())
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 255, 0, 0, 255)
                ImGui.PushStyleColor(ImGuiCol.Text, 0, 0, 0, 0)
                ImGui.ProgressBar(xtargetRatio[currentXtarget], -1, 5)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() - 3)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0, 0, 255, 255)
                ImGui.ProgressBar(xtargetManaRatio[currentXtarget], -1, 5)
                ImGui.PopStyleColor(3)
                ImGui.SetCursorPos(cursorPos)
                xtargetButtons[currentXtarget] = ImGui.InvisibleButton(mq.TLO.Spawn(charTable.XTarget[currentXtarget]).Name(),128, 29)
                if xtargetButtons[currentXtarget] then
                    utils.driverActor:send({mailbox='box', script='puppetmaster/box', character=charName}, {id ='newTarget', charName = charName, targetId =mq.TLO.Spawn(charTable.XTarget[currentXtarget]).DisplayName()})
                end
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 5)
            end
        end
    end
end

return xtargetWindow

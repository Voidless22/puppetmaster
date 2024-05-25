local mq = require('mq')
local ImGui = require('ImGui')
local msgHandler = require('msgHandler')
local utils = require('utils')
local dataHandler = require('dataHandler')
local groupWindow = {}
groupWindow.followMATarget = false
groupWindow.chaseToggle = false
groupWindow.mimicSitting = "Sit"
groupWindow.previousGroup = { 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', }
local GrpHPRatio = {}
local GrpManaRatio = {}
function groupWindow.DrawGroupWindow(charName, charTable)
    ImGui.SetWindowSize("Group-" .. charName, 128, 325, ImGuiCond.FirstUseEver)
    local groupButtons = {}
    ImGui.SetCursorPos(15, 1)
    ImGui.Text("%s's Group", charName)
    if charTable.Group ~= nil then
        ImGui.SetCursorPos(4, 20)
        -- for each member in the character's group table
        for index, value in ipairs(charTable.Group) do
            local cursorPos = ImGui.GetCursorPosVec()
            if value then
                -- Display the name
                ImGui.Text(value)
                -- if the name is me, use my PctHP/Mana values in the data Table
                if value == charName then
                    GrpHPRatio[index] = (charTable.PctHP / 100) or 0
                    GrpManaRatio[index] = (charTable.PctMana / 100) or 0
                    -- else if the name isn't me, but they have an entry in the box data table
                elseif dataHandler.boxes[value] and dataHandler.boxes[value].PctHP and dataHandler.boxes[value].PctMana then
                    GrpHPRatio[index] = (dataHandler.boxes[value].PctHP / 100) or 0
                    GrpManaRatio[index] = (dataHandler.boxes[value].PctMana / 100) or 0
                    -- if it isn't ourself and we can't find them in the data table, use their spawn data if they're in the zone
                elseif mq.TLO.Spawn(value)() then
                    GrpHPRatio[index] = (mq.TLO.Spawn(value).PctHPs() / 100) or 0
                    GrpManaRatio[index] = (mq.TLO.Spawn(value).PctMana() / 100) or 0
                else
                    -- otherwise default to 0
                    GrpHPRatio[index] = 0
                    GrpManaRatio[index] = 0
                end

                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 255, 0, 0, 255)
                ImGui.PushStyleColor(ImGuiCol.Text, 0, 0, 0, 0)
                ImGui.ProgressBar((GrpHPRatio[index]), -1, 5)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() - 3)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0, 0, 255, 255)
                ImGui.ProgressBar((GrpManaRatio[index]), -1, 5)
                ImGui.PopStyleColor(3)
                ImGui.SetCursorPos(cursorPos)
                groupButtons[index] = ImGui.InvisibleButton((mq.TLO.Spawn(value).Name() or ""), 128, 35)
            end

            if groupButtons[index] then
                if charName ~= mq.TLO.Me.Name() then
                    local newTargetMsg = { id = 'newTarget', charName = charName, targetId = mq.TLO.Spawn(charTable
                    .Group[index]).Name() }
                    utils.driverActor:send(msgHandler.boxAddress, newTargetMsg)
                else
                    mq.cmdf('/mqtarget id %i', mq.TLO.Spawn(charTable.Group[index]).ID())
                end
            end
            ImGui.SetCursorPos(4, ImGui.GetCursorPosY())
        end
    end
end

return groupWindow

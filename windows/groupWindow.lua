local mq = require('mq')
local ImGui = require('ImGui')
local msgHandler = require('msgHandler')
local utils = require('utils')

local groupWindow = {}
groupWindow.followMATarget = false
groupWindow.chaseToggle = false
groupWindow.mimicSitting = "Sit"
groupWindow.previousGroup = { 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', }

function groupWindow.DrawGroupWindow(charName, charTable)
    local GrpHPRatio = {}
    local GrpManaRatio = {}

    ImGui.SetWindowSize("Group-" .. charName, 128, 325, ImGuiCond.FirstUseEver)
    local groupButtons = {}
    ImGui.SetCursorPos(15, 1)
    ImGui.Text("%s's Group", charName)
    if charTable.Group ~= nil then
        ImGui.SetCursorPos(4, 20)
        for index, value in ipairs(charTable.Group) do
            local cursorPos = ImGui.GetCursorPosVec()

            if value and mq.TLO.Spawn(value)() then
                GrpHPRatio[index] = (charTable.PctHP / 100) or 0
                GrpManaRatio[index] = charTable.PctMana / 100 or 0

                ImGui.Text(mq.TLO.Spawn(value).Name())
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 255, 0, 0, 255)
                ImGui.PushStyleColor(ImGuiCol.Text, 0, 0, 0, 0)
                ImGui.ProgressBar(GrpHPRatio[index], -1, 5)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() - 3)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0, 0, 255, 255)
                ImGui.ProgressBar(GrpManaRatio[index], -1, 5)
                ImGui.PopStyleColor(3)
                ImGui.SetCursorPos(cursorPos)
                if mq.TLO.Group.Member(index)() or mq.TLO.Spawn(value)() then
                    groupButtons[index] = ImGui.InvisibleButton(
                        mq.TLO.Spawn(value).Name(), 128, 35)
                end

                if groupButtons[index] then
                    if charName ~= mq.TLO.Me.Name() then
                        utils.driverActor:send({ mailbox = 'Box', script = 'puppetmaster/box', char = charName },
                            {
                                id = 'newTarget',
                                charName = charName,
                                targetId = mq.TLO.Spawn(charTable.Group[index])
                                    .Name()
                            })
                    else
                        mq.cmdf('/mqtarget id %i', mq.TLO.Spawn(charTable.Group[index]).ID())
                    end
                end
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY())
            end
        end
    end
end

return groupWindow

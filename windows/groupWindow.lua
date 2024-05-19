local mq = require('mq')
local ImGui = require('ImGui')
local msgHandler = require('msgHandler')


local groupWindow = {}
groupWindow.followMATarget = false
groupWindow.chaseToggle = false
groupWindow.mimicSitting = "Sit"
groupWindow.previousGroup = { 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', }

function groupWindow.DrawGroupWindow(charName, charTable)
    local GrpHPRatio = {}
    local GrpManaRatio = {}

    ImGui.SetWindowSize("Group-" .. charName, 128, 325,ImGuiCond.FirstUseEver)
    local groupButtons = {}
    ImGui.SetCursorPos(15, 1)
    ImGui.Text("%s's Group", charName)
    if charTable.Group ~= nil then
        ImGui.SetCursorPos(4, 20)
        for currentMember = 0, #charTable.Group do
            if charTable.Group[currentMember] ~= nil and charTable.Group[currentMember] ~= 'Empty' and mq.TLO.Spawn(charTable.Group[currentMember])() ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                GrpHPRatio[currentMember] = mq.TLO.Spawn(charTable.Group[currentMember]).PctHPs() / 100 or 0
                GrpManaRatio[currentMember] = mq.TLO.Group.Member(mq.TLO.Spawn(charTable.Group[currentMember]).Name())
                    .PctMana() / 100 or 0
                ImGui.Text(mq.TLO.Spawn(charTable.Group[currentMember]).Name())
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 255, 0, 0, 255)
                ImGui.PushStyleColor(ImGuiCol.Text, 0, 0, 0, 0)
                ImGui.ProgressBar(GrpHPRatio[currentMember], -1, 5)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() - 3)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0, 0, 255, 255)
                ImGui.ProgressBar(GrpManaRatio[currentMember], -1, 5)
                ImGui.PopStyleColor(3)
                ImGui.SetCursorPos(cursorPos)
                groupButtons[currentMember] = ImGui.InvisibleButton(
                    mq.TLO.Spawn(charTable.Group[currentMember]).Name(), 128,
                    35)
                if groupButtons[currentMember] then
                    if charName ~= mq.TLO.Me.Name() then
                        msgHandler.DriverActor:send({ mailbox = 'Box', script = 'puppetmaster/box', char = charName },
                            {
                                id = 'newTarget',
                                charName = charName,
                                targetId = mq.TLO.Spawn(charTable.Group[currentMember])
                                    .Name()
                            })
                    else
                        mq.cmdf('/mqtarget id %i', mq.TLO.Spawn(charTable.Group[currentMember]).ID())
                    end 
                end
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY())
            end
        end
    end
end

return groupWindow

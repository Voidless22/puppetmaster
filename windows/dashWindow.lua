local mq = require('mq')
local ImGui = require('ImGui')
local msgHandler = require('msgHandler')
local dashWindow = {}
local chaseToggle

local sittingText
function dashWindow.DrawControlDash(charName, charTable)
    ImGui.SetWindowSize('Dash-' .. charName, 128, 150)
    -- Settings Button
    ImGui.SetCursorPos(4, 4)
    ImGui.PushStyleColor(ImGuiCol.Text, 255, 255, 255, 255)
    local settingsButton = ImGui.Button("Settings", 60, 20)
    -- Sit Button
    ImGui.SetCursorPos(64, 4)
    if charTable.Sitting then sittingText = "Sitting" else sittingText = "Standing" end
    local sitButton = ImGui.Button(sittingText, 60, 20)
    ImGui.SetCursorPos(4, 25)
    -- Attack button
    if charTable.meleeTarget then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    elseif not charTable.meleeTarget then
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
    local attackButton = ImGui.Button("Melee Atack", 120, 20)
    -- Clear Target Button
    ImGui.SetCursorPos(4, 46)
    ImGui.PushStyleColor(ImGuiCol.Text, 255, 255, 255, 255)
    local clearTargetButton = ImGui.Button("Clear Target", 120, 20)
    -- Chase Button
    ImGui.SetCursorPos(4, 68)
    if charTable.chaseToggle then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    elseif not charTable.chaseToggle then
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
    local chaseToggleButton = ImGui.Button("Chase Assist", 120, 20)
    -- Follow MA Target Button
    ImGui.SetCursorPos(4, 89)
    if charTable.followMATarget then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    elseif not charTable.followMATarget then
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
    local followTargetButton = ImGui.Button("Mirror Target", 120, 20)
    -- Char Name Footer
    ImGui.PushStyleColor(ImGuiCol.Text, 255, 255, 255, 255)
    ImGui.SetCursorPos(4, 130)
    ImGui.Text("%s's Dash", charName)

    ImGui.PopStyleColor(6)
    if settingsButton then
        OpenMimicSettings = not OpenMimicSettings
    end
    if followTargetButton then
        if charTable.followMATarget == nil then
            charTable.followMATarget = false
        end
        charTable.followMATarget = not charTable.followMATarget
        msgHandler.DriverActor:send(msgHandler.boxAddress,
            { id = 'updateFollowMATarget', charName = charName, followMATarget = charTable.followMATarget })
    end
    if clearTargetButton then
        msgHandler.DriverActor:send(msgHandler.boxAddress,
            { id = 'clearTarget', charName = charName })
    end
    if attackButton then
        charTable.meleeTarget = not charTable.meleeTarget
        msgHandler.DriverActor:send(msgHandler.boxAddress,
            { id = 'updateMeleeTarget', charName = charName, meleeTarget = charTable.meleeTarget })
    end
    if chaseToggleButton then
        if charTable.chaseToggle == nil then
            charTable.chaseToggle = false
        end
        charTable.chaseToggle = not charTable.chaseToggle
        msgHandler.DriverActor:send(msgHandler.boxAddress,
            { id = 'updateChase', charName = charName, chaseAssist = charTable.chaseToggle })
    end
    if sitButton then
        msgHandler.DriverActor:send(msgHandler.boxAddress,
            { id = 'switchSitting', charName = charName })
    end
end

return dashWindow

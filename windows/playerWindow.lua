local mq = require('mq')
local imgui = require('ImGui')
-- A_PWCSDebuff
-- A_PWCSRegen
-- A_PWCSStanding
-- A PWCSCombat?
local playerWindow = {}

local standingTexture = mq.FindTextureAnimation('A_PWCSStanding')
local regenTexture = mq.FindTextureAnimation('A_PWCSRegen')
local debuffTexture = mq.FindTextureAnimation('A_PWCSDebuff')
local combatTexture = mq.FindTextureAnimation('A_PWCSCombat')
local maTexture = mq.FindTextureAnimation('A_Assist')
local mtTexture = mq.FindTextureAnimation('A_Tank')
local pullerTexture = mq.FindTextureAnimation('A_Puller')
local hpRatio
local manaRatio
local endRatio
function playerWindow.DrawPlayerWindow(charName, playerData)
    ImGui.SetWindowSize("Player-" .. charName, 250, 100, ImGuiCond.FirstUseEver)
    ImGui.SetCursorPos(8, 4)
    ImGui.Text(charName)
    ImGui.SetCursorPosX(ImGui.GetWindowSizeVec().x - 40)
    ImGui.SetCursorPosY(4)

    local combatState = playerData.CombatState
    if combatState == 'ACTIVE' then
        ImGui.DrawTextureAnimation(standingTexture, 32, 32)
    elseif combatState == 'RESTING' then
        ImGui.DrawTextureAnimation(regenTexture, 32, 32)
    elseif combatState == 'DEBUFFED' then
        ImGui.DrawTextureAnimation(debuffTexture, 32, 32)
    elseif combatState == 'COMBAT' then
        ImGui.DrawTextureAnimation(combatTexture, 32, 32)
    end
    ImGui.SetCursorPosX(ImGui.GetWindowSizeVec().x - 60)

    ImGui.SetCursorPosY(4)
    local MA = mq.TLO.Group.MainAssist()
    local MT = mq.TLO.Group.MainTank()
    local Puller = mq.TLO.Group.Puller()
    if MA == charName then
        ImGui.DrawTextureAnimation(maTexture, 16, 16)
    end
    ImGui.SetCursorPosX(ImGui.GetWindowSizeVec().x - 80)
    ImGui.SetCursorPosY(4)

    if MT == charName then
        ImGui.DrawTextureAnimation(mtTexture, 16, 16)
    end
    ImGui.SetCursorPosX(ImGui.GetWindowSizeVec().x - 100)
    ImGui.SetCursorPosY(4)

    if Puller == charName then
        ImGui.DrawTextureAnimation(pullerTexture, 16, 16)
    end

    if playerData.PctHP and playerData.PctMana and playerData.PctEnd then
        hpRatio = (playerData.PctHP / 100) or 0
        manaRatio = (playerData.PctMana / 100) or 0
        endRatio = (playerData.PctEnd / 100) or 0

        ImGui.SetCursorPos(8, 40)
        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 255, 0, 0, 255)
        ImGui.ProgressBar(hpRatio, -1, 15)
        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0, 0, 255, 255)
        ImGui.ProgressBar(manaRatio, -1, 15)

        ImGui.SetCursorPos(8, ImGui.GetCursorPosY() - 3)
        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 50, 50, 0, 255)
        ImGui.ProgressBar(endRatio, -1, 15)

        ImGui.PopStyleColor(3)
        
    end
end

return playerWindow

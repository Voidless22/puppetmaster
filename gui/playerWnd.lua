local mq = require('mq')
local imgui = require('ImGui')
-- A_PWCSDebuff
-- A_PWCSRegen
-- A_PWCSStanding
-- A PWCSCombat?
PlayerWnd = {}

local standingTexture = mq.FindTextureAnimation('A_PWCSStanding')
local regenTexture = mq.FindTextureAnimation('A_PWCSRegen')
local debuffTexture = mq.FindTextureAnimation('A_PWCSDebuff')
local combatTexture = mq.FindTextureAnimation('A_PWCSCombat')

function PlayerWnd.DrawPlayerWindow(playerData)
    local hpRatio
    local manaRatio
    local endRatio
    ImGui.SetWindowSize("##Player" .. mq.TLO.Me.Name(), 250, 100, ImGuiCond.FirstUseEver)
    ImGui.SetCursorPos(8, 4)
    ImGui.Text(mq.TLO.Me.Name())
    ImGui.SetCursorPosX(ImGui.GetWindowSizeVec().x - 40)
    ImGui.SetCursorPosY(4)

    local combatState = mq.TLO.Me.CombatState()
    if combatState == 'ACTIVE' then
        ImGui.DrawTextureAnimation(standingTexture, 32, 32)
    elseif combatState == 'RESTING' then
        ImGui.DrawTextureAnimation(regenTexture, 32, 32)
    elseif combatState == 'DEBUFFED' then
        ImGui.DrawTextureAnimation(debuffTexture, 32, 32)
    elseif combatState == 'COMBAT' then
        ImGui.DrawTextureAnimation(combatTexture, 32, 32)
    end
    if mq.TLO.Me.Name() ~= mq.TLO.Me.Name() then
        hpRatio = mq.TLO.Spawn(mq.TLO.Me.Name()).PctHPs() / 100 or 0
        manaRatio = mq.TLO.Spawn(mq.TLO.Me.Name()).PctMana() / 100 or 0
        endRatio = mq.TLO.Spawn(mq.TLO.Me.Name()).PctEndurance() / 100 or 0
    else
        hpRatio = mq.TLO.Me.PctHPs() / 100 or 0
        manaRatio = mq.TLO.Me.PctMana() / 100 or 0
        endRatio = mq.TLO.Me.PctEndurance() / 100 or 0
    end

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

return PlayerWnd

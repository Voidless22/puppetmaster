local mq = require('mq')
local ImGui = require('ImGui')

TargetWnd = {}

TargetWnd.mimicTargetId = 'Empty'
TargetWnd.previousTarget = 'Empty'
local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

function TargetWnd.DrawTargetWindow(playerData)
    local currentColumn = 1
    local currentRow = 1
    local targetHPRatio
    local currentTarget = playerData.currentTarget[mq.TLO.Me.Name()][1]
    local currentTargetBuffs = playerData.targetBuffs[mq.TLO.Me.Name()]
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor(windowWidth / 32)

    ImGui.SetWindowSize("Target" .. mq.TLO.Me.Name(), 140, 256, ImGuiCond.FirstUseEver)
    ImGui.SetCursorPos(4, 0)
    ImGui.Text("%s's Target", mq.TLO.Me.Name())
    ImGui.SetCursorPos(4, 20)
    if currentTarget ~= 'Empty' and mq.TLO.Spawn(currentTarget)() ~= nil then
        targetHPRatio = mq.TLO.Spawn(currentTarget).PctHPs() / 100 or 0
        ImGui.Text(mq.TLO.Spawn(currentTarget).DisplayName())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(targetHPRatio, -1, 15)
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)

        ImGui.SetCursorPos(4, 60)
        if currentTargetBuffs ~= nil then
            for _, buff in pairs(currentTargetBuffs) do
                animSpellIcons:SetTextureCell(mq.TLO.Spell(buff).SpellIcon())
                if currentColumn < columnCount then
                    local prevX = ImGui.GetCursorPosX()
                    local prevY = ImGui.GetCursorPosY()
                    ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                    ImGui.SetCursorPosX(prevX + 32)
                    ImGui.SetCursorPosY(prevY)
                    currentColumn = currentColumn + 1
                elseif currentColumn >= columnCount then
                    local prevY = ImGui.GetCursorPosY()
                    ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                    ImGui.SetCursorPosX(4)
                    ImGui.SetCursorPosY(prevY + 32)
                    currentRow = currentRow + 1
                    currentColumn = 1
                end
            end
        end
    end
end

return TargetWnd

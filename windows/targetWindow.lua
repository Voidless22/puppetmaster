local mq = require('mq')
local ImGui = require('ImGui')

local targetWindow = {}

targetWindow.targetId = 'Empty'
targetWindow.previousTarget = 'Empty'
local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

function targetWindow.DrawTargetWindow(charName, charTable)
    local currentColumn = 1
    local currentRow = 1
    local targetHPRatio
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor(windowWidth / 32)
    ImGui.SetWindowSize("Target-" .. charName, 140, 256)
    ImGui.SetCursorPos(4, 0)
    ImGui.Text("%s's Target", charName)
    ImGui.SetCursorPos(4, 20)
    if charTable.targetID ~= 'Empty' and mq.TLO.Spawn(charTable.targetID)() ~= nil then
        targetHPRatio = mq.TLO.Spawn(charTable.targetID).PctHPs() / 100 or 0
        ImGui.Text(mq.TLO.Spawn(charTable.targetID).DisplayName())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(targetHPRatio, -1, 15)
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        local rowCount = 0
        if charTable.targetBuffs ~= nil then
            for _, buff in ipairs(charTable.targetBuffs) do
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

return targetWindow

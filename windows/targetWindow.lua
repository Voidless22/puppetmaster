local mq = require('mq')
local ImGui = require('ImGui')
local utils = require('utils')

local targetWindow = {}

targetWindow.targetId = 'Empty'
targetWindow.previousTarget = 'Empty'
local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

function targetWindow.DrawTargetWindow(charName, charTable)
    local currentColumn = 1
    local currentRow = 1
    local targetHPPct
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor(windowWidth / 32)
    ImGui.SetWindowSize("Target-" .. charName, 140, 256, ImGuiCond.FirstUseEver)
    ImGui.SetCursorPos(4, 0)
    ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize(charName.."'s Target")) * 0.5)
    ImGui.Text("%s's Target", charName)
    ImGui.Separator()
    ImGui.SetCursorPos(4, 22)
    if charTable.targetID and mq.TLO.Spawn(charTable.targetID)() and charTable.targetConColor then
        targetHPPct = mq.TLO.Spawn(charTable.targetID).PctHPs() / 100 or 0
        if charTable.targetConColor == "GREY" then
            
            ImGui.PushStyleColor(ImGuiCol.Text, utils.Color("Grey",1))
        elseif charTable.targetConColor == "GREEN" then
            ImGui.PushStyleColor(ImGuiCol.Text, utils.Color("Green",1))
        elseif charTable.targetConColor == "LIGHT BLUE" then
            ImGui.PushStyleColor(ImGuiCol.Text, utils.Color("Light Blue",1))
        elseif charTable.targetConColor == "BLUE" then
            ImGui.PushStyleColor(ImGuiCol.Text, utils.Color("Blue",1))
        elseif charTable.targetConColor == "YELLOW" then
            ImGui.PushStyleColor(ImGuiCol.Text, utils.Color("Yellow",1))
        elseif charTable.targetConColor == "RED" then
            ImGui.PushStyleColor(ImGuiCol.Text, utils.Color("Red",1))
        end
        ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize(mq.TLO.Spawn(charTable.targetID).DisplayName())) * 0.5)
        ImGui.Text(mq.TLO.Spawn(charTable.targetID).DisplayName())
        ImGui.PopStyleColor(1)
        ImGui.Separator()
        ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize("Lvl:".. mq.TLO.Spawn(charTable.targetID).Level().."   "..mq.TLO.Spawn(charTable.targetID).Class())) * 0.5)
        ImGui.Text("Lvl:%i", mq.TLO.Spawn(charTable.targetID).Level())
        ImGui.SameLine()
        ImGui.Text(mq.TLO.Spawn(charTable.targetID).Class())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(targetHPPct, -1, 15)
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

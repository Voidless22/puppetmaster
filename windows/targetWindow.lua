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
    local cTData = charTable.Target
    if cTData then
        local cTSpawn = mq.TLO.Spawn(cTData.id)

        ImGui.SetWindowSize("Target-" .. charName, 140, 256, ImGuiCond.FirstUseEver)
        ImGui.SetCursorPos(4, 0)
        ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize(charName .. "'s Target")) * 0.5)
        ImGui.Text("%s's Target", charName)
        ImGui.Separator()
        ImGui.SetCursorPos(4, 22)
        if cTData.id and cTSpawn() and cTData.ConColor then
            targetHPPct = cTSpawn.PctHPs() / 100 or 0
            ImGui.PushStyleColor(ImGuiCol.Text, utils.GetConTextColor(charTable.Target.ConColor))
            ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize(cTSpawn.DisplayName())) * 0.5)
            ImGui.Text(cTSpawn.DisplayName())
            ImGui.PopStyleColor(1)
            ImGui.Separator()
            ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize("Lvl:" .. cTSpawn.Level() .. "   " .. cTSpawn.Class())) *
            0.5)
            ImGui.Text("Lvl:%i", cTSpawn.Level())
            ImGui.SameLine()
            ImGui.Text(cTSpawn.Class())
            ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
            ImGui.ProgressBar(targetHPPct, -1, 15)
            ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)

            local rowCount = 0
            if charTable.Target.Buffs ~= nil then
                for _, buff in ipairs(charTable.Target.Buffs) do
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
end

return targetWindow

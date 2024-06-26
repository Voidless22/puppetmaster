local mq = require('mq')
local ImGui = require('ImGui')
local utils = require('utils')
local msgHandler = require('msgHandler')

local buffWindow = {}

local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

function buffWindow.DrawBuffWindow(charName, charTable)
    ImGui.SetWindowSize("Buffs-" .. charName, 150, 150, ImGuiCond.FirstUseEver)
    ImGui.Text('Buffs: %s', charName)
    local buffNames = charTable.BuffIds
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor(windowWidth / 32)
    local currentColumn = 1
    local currentRow = 1

    if buffNames ~= nil then
        for index, data in ipairs(buffNames) do
            if data ~= 0 then
                animSpellIcons:SetTextureCell(mq.TLO.Spell(data).SpellIcon())
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
                if ImGui.IsItemHovered(ImGuiHoveredFlags.DelayNormal) then
                    if ImGui.IsMouseClicked(ImGuiMouseButton.Left) then
                    if charName ~= mq.TLO.Me.Name() then
                        utils.driverActor:send(msgHandler.boxAddress, {id='removeBuff', buff=data, charName = charName})
                    else
                        mq.TLO.Me.Buff(mq.TLO.Spell(data).Name()).Remove()
                    end

                    end
                    if ImGui.BeginTooltip() then
                        if data ~= 0 then
                        ImGui.Text(mq.TLO.Spell(data).Name()..' '.. charTable.BuffDurations[index])
                        else
                        ImGui.Text('Empty')
                        end

                        ImGui.EndTooltip()
                    end
                end
            end
        end
    end
end

return buffWindow

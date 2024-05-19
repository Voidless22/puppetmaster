local mq = require('mq')
local imgui = require('ImGui')
local icons = require('icons')
local spellbarWnd = {}
local msgHandler = require('msgHandler')

spellbarWnd.spellbarIds = {}
spellbarWnd.previousSpellbar = {}

function spellbarWnd.DrawSpellbar(charName, charTable)
    local gemButtons = {}
    local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')
    local spellIds = charTable.Spellbar
    local cursorPos
    local screenCursorPos
    ImGui.SetWindowSize("Spellbar-" .. charName, 40, 360)
    ImGui.SetCursorPos(4, 4)

    if spellIds then
        ImGui.SetWindowSize('Spellbar-' .. charName, 40, ((#spellIds + 2) * 36))
        for currentGem = 1, #spellIds do
            if spellIds[currentGem] == 0 then
                cursorPos = ImGui.GetCursorPosVec()
                ImGui.SetCursorPos(cursorPos.x, cursorPos.y + 40)
            elseif spellIds[currentGem] ~= 0  then
                cursorPos = ImGui.GetCursorPosVec()
                screenCursorPos = ImGui.GetCursorScreenPosVec()

                if charTable.isCasting and charTable.lastCastGem == currentGem then
                    local drawlist = ImGui.GetWindowDrawList()
                    local x = screenCursorPos.x + 34
                    local y = screenCursorPos.y + 34
                    local color = ImGui.GetColorU32(ImVec4(255, 0, 0, 255))
                    drawlist:AddRectFilled(screenCursorPos, ImVec2(x, y), color, 5)
                else
                    animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())
                    ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                end
                ImGui.SetCursorPos(cursorPos)
                gemButtons[currentGem] = ImGui.InvisibleButton((mq.TLO.Spell(spellIds[currentGem]).Name() or "Empty"), 32, 32)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 4)

                if ImGui.IsItemHovered() then
                    if ImGui.BeginTooltip() then
                        ImGui.Text((mq.TLO.Spell(spellIds[currentGem]).Name() or "Empty"))
                        ImGui.EndTooltip()
                    end
                end

                if gemButtons[currentGem] and charName ~= mq.TLO.Me.Name() then
                    msgHandler.DriverActor:send(msgHandler.boxAddress,
                        { id = 'castSpell', charName = charName, gem = currentGem })
                end
            end
        end
    end
    ImGui.PushStyleColor(ImGuiCol.Button, 0.0, 0.0, 0.0, 0.0)
    local loadoutButton = ImGui.Button(icons.MD_BORDER_COLOR, 32, 32)
    if loadoutButton then
        Settings.OpenLoadout[charName] = not Settings.OpenLoadout[charName]
    end
    ImGui.PopStyleColor(1)
end

return spellbarWnd

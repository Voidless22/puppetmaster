local mq = require('mq')
local imgui = require('ImGui')
local icons = require('icons')
local spellbarWnd = {}
local msgHandler = require('msgHandler')

spellbarWnd.spellbarIds = {}
spellbarWnd.previousSpellbar = {}

function spellbarWnd.DrawSpellbar(charName, charTable)
    local gemButtons = {}

    local spellIds = charTable.Spellbar
    ImGui.SetWindowSize("Spellbar-" .. charName, 40, 360)
    ImGui.SetCursorPos(4, 4)
    local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

    if spellIds ~= nil then
        for currentGem = 1, #spellIds do
            if spellIds[currentGem] == 'Empty' or spellIds[currentGem] == nil then
                local curx = ImGui.GetCursorPosX()
                local cury = ImGui.GetCursorPosY()
                ImGui.SetCursorPos(curx, cury + 40)
            elseif spellIds[currentGem] ~= 'Empty' and spellIds[currentGem] ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                local screenCursorPos = ImGui.GetCursorScreenPosVec()

                if charTable['isCasting'] ~= nil and charTable['isCasting'] == mq.TLO.Spell(spellIds[currentGem]).Name() then
                    local drawlist = ImGui.GetWindowDrawList()
                    local x = screenCursorPos.x + 34
                    local y = screenCursorPos.y + 34
                    local color = ImGui.GetColorU32(ImVec4(255, 0, 0, 255))
                    drawlist:AddRectFilled(screenCursorPos, ImVec2(x, y), color, 5)
                elseif charTable['isCasting'] ~= mq.TLO.Spell(spellIds[currentGem]).Name() then
                    animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())
                    ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                end
                ImGui.SetCursorPos(cursorPos)
                gemButtons[currentGem] = ImGui.InvisibleButton(mq.TLO.Spell(spellIds[currentGem]).Name(), 32, 32)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 4)

                if ImGui.IsItemHovered() then
                    if ImGui.BeginTooltip() then
                        ImGui.Text(mq.TLO.Spell(spellIds[currentGem]).Name())
                        ImGui.EndTooltip()
                    end
                end

                if gemButtons[currentGem] and charName ~= mq.TLO.Me.Name() then
                    msgHandler.DriverActor:send({ mailbox = 'Box', script = 'puppetmaster/box', character = charName },
                        { id = 'castSpell', charName = charName, gem = currentGem })
                end
            end
        end
    end
    ImGui.PushStyleColor(ImGuiCol.Button, 0.0, 0.0, 0.0, 0.0)
    local loadoutButton = ImGui.Button(icons.MD_BORDER_COLOR, 32, 32)
    if loadoutButton then
        Settings['OpenMimicLoadoutWindow'][charName] = not Settings['OpenMimicLoadoutWindow'][charName]
    end
    ImGui.PopStyleColor(1)
end

return spellbarWnd

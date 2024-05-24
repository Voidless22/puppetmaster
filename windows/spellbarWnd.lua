local mq = require('mq')
local imgui = require('ImGui')
local icons = require('icons')
local spellbarWnd = {}
local utils = require('utils')
local msgHandler = require('msgHandler')

spellbarWnd.spellbarIds = {}



function spellbarWnd.DrawSpellbar(charName, charTable)
    local gemButtons = {}
    local gemBG = mq.FindTextureAnimation('A_SpellGemBackground')
    local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')
    local spellIds = charTable.Spellbar
    local cursorPos
    local screenCursorPos
    ImGui.SetWindowSize("Spellbar-" .. charName, 40, 360)
    ImGui.SetCursorPos(4, 4)

    if spellIds then
        -- Set the spellbar size to our max Gem count, plus room for the loadout button
        ImGui.SetWindowSize('Spellbar-' .. charName, 40, ((#charTable.Spellbar + 2) * 36))
        ImGui.SetCursorPosX(4)
        for currentGem = 1, #spellIds do
            ImGui.SetCursorPosX(4)

            -- if we don't have a spell in the gem, move to the next gem spot and leave it empty
            if spellIds[currentGem] == 0 then
                cursorPos = ImGui.GetCursorPosVec()
                ImGui.SetCursorPos(cursorPos.x, cursorPos.y + 40)
            elseif spellIds[currentGem] ~= 0 then
                cursorPos = ImGui.GetCursorPosVec()
                screenCursorPos = ImGui.GetCursorScreenPosVec()
                -- if we're casting and our last gem cast is this one, draw a red rect in the position where the gem icon would be
                if charTable.isCasting and charTable.lastCastGem == currentGem then
                    local drawlist = ImGui.GetWindowDrawList()
                    local x = screenCursorPos.x + 32
                    local y = screenCursorPos.y + 32
                    local color = ImGui.GetColorU32(1,0,0,0.25)
                   animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())
                   ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                   drawlist:AddRectFilled(screenCursorPos, ImVec2(x, y),color)


                   ImGui.SetCursorPos(cursorPos)
                    ImGui.SetCursorPos(cursorPos + ImVec2(11,8))
                    ImGui.Text(charTable.CastTimeLeft)

                else
                    -- otherwise just draw our normal texture
        
                    animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())

                    ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                end
                --move back overtop of the gem icon and add an invisible button to the gem array, then move to the next gem spot
                ImGui.SetCursorPos(cursorPos)
                gemButtons[currentGem] = ImGui.InvisibleButton((mq.TLO.Spell(spellIds[currentGem]).Name() or "Empty"), 32,
                    32)
                -- Spell Name Tooltip
                if ImGui.IsItemHovered(ImGuiHoveredFlags.DelayNormal) then
                    if ImGui.BeginItemTooltip() then
                        ImGui.Text((mq.TLO.Spell(spellIds[currentGem]).Name()) or "Empty")
                        ImGui.Text(("Type: "..mq.TLO.Spell(spellIds[currentGem]).TargetType()) or "Empty")
                        ImGui.EndTooltip()
                    end
                end
                -- On Gem Clicked
                if gemButtons[currentGem] then
                    if charName ~= mq.TLO.Me.Name() then
                        utils.driverActor:send(msgHandler.boxAddress,
                            { id = 'castSpell', charName = charName, gem = currentGem })
                    else
                        mq.cmdf('/cast %i', currentGem)
                        charTable.lastCastGem = currentGem
                    end
                end
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 4)

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

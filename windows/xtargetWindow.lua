local mq = require('mq')
local imgui = require('ImGui')
local msgHandler = require('msgHandler')
local utils = require('utils')
local xtargetWindow = {}
local function GetConTextColor(conColor)
    if conColor == "GREY" then
        return utils.Color("Grey", 1)
    elseif conColor == "GREEN" then
        return utils.Color("Green", 1)
    elseif conColor == "LIGHT BLUE" then
        return utils.Color("Light Blue", 1)
    elseif conColor == "BLUE" then
        return utils.Color("Blue", 1)
    elseif conColor == "YELLOW" then
        return utils.Color("Yellow", 1)
    elseif conColor == "RED" then
        return utils.Color("Red", 1)
    elseif conColor == "WHITE" then
        return utils.Color("White", 1)
    else
        -- default white
        return ImVec4(1, 1, 1, 1)
    end
end
function xtargetWindow.DrawMimicXTargetWindow(charName, charTable)
    ImGui.SetWindowSize("XTarget-" .. charName, 128, 256, ImGuiCond.FirstUseEver)
    local xtargetHPPct = {}
    local xtargetButtons = {}
    local cursorPos
    ImGui.Text("%s's XTarget", charName)
    if charTable.XTarget ~= nil then
        for xtIndex = 1, #charTable.XTarget do
            local cXTData = charTable.XTarget[xtIndex]
            local cXTSpawn = mq.TLO.Spawn(cXTData.Id)
            if cXTData and cXTSpawn() then
                -- this is our cursor starting point
                cursorPos = ImGui.GetCursorPosVec()
                -- create pct of xt spawn hp for progress bar
                xtargetHPPct[xtIndex] = cXTSpawn.PctHPs() / 100 or 0
                -- set the text color to con color if it exists, otherwise just draw white
                if cXTData.ConColor ~= 0 and cXTData.ConColor then
                    ImGui.PushStyleColor(ImGuiCol.Text, GetConTextColor(cXTData.ConColor))
                    ImGui.Text(cXTSpawn.CleanName())
                    ImGui.PopStyleColor()
                else
                    ImGui.Text(cXTSpawn.CleanName())
                end
                -- draw HP bar
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, utils.Color("Red", 1))
                ImGui.PushStyleColor(ImGuiCol.Text, 0, 0, 0, 0)
                ImGui.ProgressBar(xtargetHPPct[xtIndex], -1, 5)
                ImGui.PopStyleColor(2)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() - 3)
                -- Draw aggro bar if it's necessary
                if cXTData.AggroPct ~= 0 then
                    ImGui.PushStyleColor(ImGuiCol.PlotHistogram, utils.Color("Green", 1))
                    ImGui.ProgressBar(cXTData.AggroPct, -1, 5)
                    ImGui.PopStyleColor(1)
                end

                ImGui.SetCursorPos(cursorPos)
                -- create dummy button for targeting
                xtargetButtons[xtIndex] = ImGui.InvisibleButton(cXTSpawn.Name(), 128, 29)
                if xtargetButtons[xtIndex] then
                    utils.driverActor:send(msgHandler.boxAddress,
                        { id = 'newTarget', charName = charName, targetId = cXTSpawn.DisplayName() })
                end
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 5)
            end
        end
    end
end

return xtargetWindow

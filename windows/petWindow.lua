local mq = require('mq')
local ImGui = require('ImGui')

local petWindow = {}

local tauntButton
function petWindow.DrawPetWindow(charName, charTable)
    local petTargetSpawn = mq.TLO.Spawn(charTable.PetTarget)
    local petSpawn = mq.TLO.Spawn(charName).Pet
    ImGui.SetWindowSize("Pet-" .. charName, 150, 180)
    ImGui.SetCursorPos(4, 5)
    if charTable.Pet ~= "No Pet" then
        local PetHP = petSpawn.PctHPs() / 100 or 0
        ImGui.Text(charName..": ".. petSpawn.CleanName())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(PetHP, -1, 15)
    end
    if charTable.PetInCombat and charTable.PetTarget ~= 'Empty' and petTargetSpawn() and not petTargetSpawn.Dead() then
        local targetHP = petTargetSpawn.PctHPs() / 100 or 0
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 5)
        ImGui.Text(petTargetSpawn.DisplayName())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(targetHP, -1, 15)
    end
    ImGui.SetCursorPos(6,100)
    local attackButton = ImGui.Button("Attack", 64, 32)
    ImGui.SetCursorPos(76, 100)

    if charTable.PetTaunt then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
     tauntButton = ImGui.Button("Taunt", 64, 32)
    ImGui.PopStyleColor()

    ImGui.SetCursorPos(6,138)
    if charTable.PetFollow then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    elseif not charTable.PetFollow then
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
    local followButton = ImGui.Button("Follow", 64, 32)
    ImGui.PopStyleColor()
    ImGui.SetCursorPosX(76)
    ImGui.SetCursorPos(76,138)
    local backOffButton = ImGui.Button("Back Off", 64, 32)


    if followButton then
        charTable.PetFollow = not charTable.PetFollow
        DriverActor:send({mailbox='Box', script='puppetmaster/box', character=charName}, {id = 'petFollowUpdate', charName = charName, PetFollow=charTable.PetFollow})

    end
    if tauntButton then
        charTable.PetTaunt = not charTable.PetTaunt
        DriverActor:send({mailbox='Box', script='puppetmaster/box', character=charName}, {id = 'petTauntUpdate', charName = charName, taunt=charTable.PetTaunt})
    end

    if attackButton then
        DriverActor:send({mailbox='Box', script='puppetmaster/box', character=charName}, {id='petAttack', charName = charName})
    end
    if backOffButton then
        DriverActor:send({mailbox='Box', script='puppetmaster/box', character=charName},{id='petBackOff',charName = charName})
    end
end

return petWindow

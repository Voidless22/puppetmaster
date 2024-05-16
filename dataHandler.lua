local mq = require('mq')
local actors = require('actors')

local dataHandler = {}

dataHandler.boxes = {}

function dataHandler.AddNewCharacter(charName)
    if not dataHandler.boxes[charName] then
        dataHandler.boxes[charName] = {}
        printf('\agDataHandler: \awEntry created in Character Data table: \at%s', charName)
    else
        printf('\agDataHandler: \arCharacter Data Entry creation attempted, but already exists.')
    end
end
function dataHandler.GetData(charName)
    if dataHandler.boxes[charName] then
        return dataHandler.boxes[charName]
    end
end


function dataHandler.UpdateData(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    currentBoxIndex.Level = mq.TLO.Me.Level()
    currentBoxIndex.Class = mq.TLO.Me.Class()
    currentBoxIndex.Race = mq.TLO.Me.Race()
    currentBoxIndex.PctHP = mq.TLO.Me.PctHPs()
    currentBoxIndex.PctMana = mq.TLO.Me.PctMana()
    currentBoxIndex.PctEnd = mq.TLO.Me.PctEndurance()
    currentBoxIndex.Spellbar = {}
    for gem = 1, mq.TLO.Me.NumGems() do
        currentBoxIndex.Spellbar[gem] = mq.TLO.Me.Gem(gem).ID()
    end
    currentBoxIndex.Spellbook = {}
    currentBoxIndex.CombatAbilities = {}
    currentBoxIndex.Group = {}
    for member = 1, mq.TLO.Me.GroupSize() do
        currentBoxIndex.Group[member] = mq.TLO.Group.Member(member).ID()
    end
    printf('\awInitializing Data: %s\n Class: %s | Race: %s\nCurrent HP: %i  | Current Mana: %i  | Current Endurance: %i ', 
    boxName, currentBoxIndex.Class, currentBoxIndex.Race,currentBoxIndex.PctHP, currentBoxIndex.PctMana, currentBoxIndex.PctEnd)
end

return dataHandler

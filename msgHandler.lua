local mq = require('mq')
local ImGui = require('ImGui')
local actors = require('actors')
local Write = require('knightlinc/Write')
local gui = require('gui/gui')
local msgHandler = {}
local boxActor
local hostActor



msgHandler.boxes = {}


function msgHandler.hostMessageHandler(message)
    local boxName = message.content.boxName
    local messageId = message.content.id
    if messageId == 'boxConnect' then
        Write.Debug("%s has connected to the host, %s.", boxName, mq.TLO.Me.Name())
        msgHandler.boxes[boxName] = { Spellbar = {}, Spellbook = {}, Stats = {}, Group = {}, Target = {}, XTarget = {}, IsCasting = false }
        gui.updateGuiData(msgHandler.boxes)
    elseif messageId == 'UpdateStats' then
        msgHandler.boxes[boxName].Stats = message.content.currentStats
        gui.updateGuiData(msgHandler.boxes)
        Write.Debug('%s: HP Pct: %s Mana Pct: %s Endurance Pct: %s', boxName, msgHandler.boxes[boxName].Stats[1],
            msgHandler.boxes[boxName].Stats
            [2], msgHandler.boxes[boxName].Stats[3])
    elseif messageId == 'UpdateSpellbar' then
        msgHandler.boxes[boxName].Spellbar = message.content.currentSpellbar
        gui.updateGuiData(msgHandler.boxes)
        for index, value in ipairs(msgHandler.boxes[boxName].Spellbar) do
            Write.Debug('%s: Spell Gem %i: %s', boxName, index, mq.TLO.Spell(value).Name())
        end
    elseif messageId == 'UpdateGroup' then
        msgHandler.boxes[boxName].Group = message.content.currentGroup
        gui.updateGuiData(msgHandler.boxes)
        if msgHandler.boxes[boxName].Group ~= nil then
            for index, value in ipairs(msgHandler.boxes[boxName].Group) do
                Write.Debug('%s: Group Member %i: %s', boxName, index, mq.TLO.Group.Member(index).Name())
            end
        end
    elseif messageId == 'UpdateTarget' then
        msgHandler.boxes[boxName].Target = message.content.currentTarget
        gui.updateGuiData(msgHandler.boxes)
        if msgHandler.boxes[boxName].Target[1] ~= nil then
            local targetName = mq.TLO.Spawn(msgHandler.boxes[boxName].Target[1]).Name()
            Write.Debug('%s: Target: %s', boxName, targetName)
        end
        if msgHandler.boxes[boxName].Target[2] ~= nil then
            for index, value in ipairs(msgHandler.boxes[boxName].Target[2]) do
                Write.Debug('Target Buff Slot %i: %s', index, mq.TLO.Spell(value).Name())
            end
        end
    elseif messageId == 'IsCasting' then
        msgHandler.boxes[boxName].IsCasting = message.content.isCasting
        gui.updateGuiData(msgHandler.boxes)
    elseif messageId == 'UpdateXTarget' then
        msgHandler.boxes[boxName].XTarget = message.content.currentXTarget
        gui.updateGuiData(msgHandler.boxes)
        if msgHandler.boxes[boxName].XTarget ~= nil then
            for index, value in ipairs(msgHandler.boxes[boxName].XTarget) do
                Write.Debug('%s: XTar Slot %i: %s', boxName, index, mq.TLO.Spawn(value).Name())
            end
        end
    end
end

function msgHandler.boxMessageHandler(message)

end

return msgHandler

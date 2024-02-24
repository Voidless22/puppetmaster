local mq         = require('mq')
local ImGui      = require('ImGui')
local actors     = require('actors')
local gui        = require('gui/gui')
local utils      = require('utils')
local msgHandler = require('msgHandler')
local Running    = true
local boxConnected = false
local boxName = mq.TLO.Me.Name()
local boxActor = actors.register('Box', msgHandler.boxMessageHandler)
local function connectToHost()
    if not boxConnected then
        boxActor:send({ mailbox = 'Host', script = 'puppetmaster' }, { id = 'boxConnect', boxName = mq.TLO.Me.Name() })
        boxConnected = true
    end
end
local function sendData()
    
    local address = {mailbox = 'Host', script = 'puppetmaster'}
local currentStats = utils.UpdateStats
local currentSpellbar = utils.GetCurrentSpellbar
local currentGroup = utils.UpdateGroup
local currentTarget = utils.UpdateTarget
local currentXTarget = utils.UpdateXTarget
local isCasting = mq.TLO.Me.Casting()
boxActor:send(address, {id = 'UpdateStats', boxName = boxName, currentStats = currentStats()})
boxActor:send(address, {id = 'UpdateSpellbar', boxName = boxName, currentSpellbar = currentSpellbar()})
boxActor:send(address, {id = 'UpdateGroup', boxName = boxName, currentGroup = currentGroup()})
boxActor:send(address, {id = 'IsCasting', boxName = boxName, isCasting = isCasting })
boxActor:send(address, {id = 'UpdateTarget', boxName = boxName, currentTarget = currentTarget()})
boxActor:send(address, {id = 'UpdateXTarget', boxName = boxName, currentXTarget = currentXTarget()})
end

connectToHost()
local function main()
    while Running do
        mq.delay(1500)
        sendData() 

    end
end

main()

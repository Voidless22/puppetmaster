local mq = require('mq')
local dataHandler = require('dataHandler')
local msgHandler = {}
msgHandler.boxes = {}
msgHandler.driverConnected = false
local ReadyToGo = false

function msgHandler.boxReady()
    return ReadyToGo
end

function msgHandler.boxMessageHandler(message)
    local msgId = message.content.id
    if msgId == 'Connect' then
        message:send({ id = 'Connect', boxName = mq.TLO.Me.Name() })
    end
    if msgId == 'ReadyToGo' then
        ReadyToGo = true
    end
end

function msgHandler.driverMessageHandler(message)
    local msgId = message.content.id
    if msgId == 'Connect' then
        printf('Connect attempt from %s', message.content.boxName)
        local boxName = message.content.boxName
        dataHandler.AddNewBox(boxName)
        if dataHandler.boxes[boxName] then
            printf('%s Connected', boxName)
            message:send({ id = 'ReadyToGo' })
        end
    end
end
return msgHandler

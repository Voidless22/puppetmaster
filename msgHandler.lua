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
    if msgId == 'UpdateData' then
       -- dataHandler.UpdateData(mq.TLO.Me.Name())
        message:send({ id = 'UpdatedData', boxName = mq.TLO.Me.Name(), boxData = dataHandler.GetData(mq.TLO.Me.Name()) })
    end
    if msgId == 'castSpell' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmdf('/cast %i', message.content.gem)
    end
    if msgId == 'newTarget' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmdf('/target %s', message.content.targetId)
    end
end

function msgHandler.driverMessageHandler(message)
    local msgId = message.content.id
    if msgId == 'Connect' then
        printf('Connect attempt from %s', message.content.boxName)
        local boxName = message.content.boxName
        dataHandler.AddNewCharacter(boxName)
        local settingsFile, err = loadfile(mq.configDir .. '/' .. 'PMSettings.lua')
        if err then
            for index, value in pairs(Settings) do
                if not Settings[index][boxName] then
                    Settings[index][boxName] = false
                end
            end
            mq.pickle('PMSettings.lua', Settings)
        elseif settingsFile then
            local fileData = settingsFile()
            for settingName, value in pairs(Settings) do
                if fileData[settingName][boxName] == nil then
                    Settings[settingName][boxName] = true
                    mq.pickle('PMSettings.lua', Settings)
                else
                    Settings[settingName][boxName] = fileData[settingName][boxName]
                end
            end
        end
        if dataHandler.boxes[boxName] then
            printf('%s Connected', boxName)
            message:send({ id = 'ReadyToGo' })
        end
    end
    if msgId == 'UpdatedData' then
        dataHandler.boxes[message.content.boxName] = message.content.boxData

    end
end

return msgHandler

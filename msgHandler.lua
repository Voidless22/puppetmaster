local mq = require('mq')
local actors = require('actors')
local dataHandler = require('dataHandler')
local msgHandler = {}
msgHandler.boxes = {}
msgHandler.driverConnected = false
local ReadyToGo = false

msgHandler.boxAddress = { mailbox = 'Box', script = 'puppetmaster/box' }
msgHandler.driverAddress = { mailbox = 'Driver', script = 'puppetmaster' }

function msgHandler.boxReady()
    return ReadyToGo
end

function msgHandler.boxMessageHandler(message)
    local msgId = message.content.id
    if msgId == 'Connect' then
        message:send({ id = 'Connect', boxName = mq.TLO.Me.Name() })
    elseif msgId == 'ReadyToGo' then
        ReadyToGo = true
    elseif msgId == 'UpdateData' then
        -- dataHandler.UpdateData(mq.TLO.Me.Name())
        message:send({ id = 'UpdatedData', boxName = mq.TLO.Me.Name(), boxData = dataHandler.GetData(mq.TLO.Me.Name()) })
    elseif msgId == 'castSpell' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmdf('/cast %i', message.content.gem)
    elseif msgId == 'newTarget' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmdf('/target %s', message.content.targetId)
    elseif message.content.id == 'petFollowUpdate' and message.content.charName == mq.TLO.Me.Name() then
        dataHandler.boxes[message.content.charName].PetFollow = message.content.PetFollow

        if message.content.PetFollow == true then
            mq.cmd('/pet follow')
        end
        if message.content.PetFollow == false then mq.cmd('/pet guard') end
        -- Pet Taunt Message
    elseif message.content.id == 'petTauntUpdate' and message.content.charName == mq.TLO.Me.Name() then
        if message.content.taunt == true then mq.cmd('/pet taunt on') end
        if message.content.taunt == false then mq.cmd('/pet taunt off') end
        -- Pet Attack Message
    elseif message.content.id == 'petAttack' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmd('/pet attack')
    elseif message.content.id == 'petBackOff' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmd('/pet stop')
        mq.cmd('/pet back')
    end
    if message.content.id == 'updateChase' then
        dataHandler.boxes[message.content.charName].chaseToggle = message.content.chaseAssist
        -- MA Target Message
    elseif message.content.id == 'updateFollowMATarget' then
        dataHandler.boxes[message.content.charName].followMATarget = message.content.followMATarget
        -- Sit Toggle Message
    elseif message.content.id == 'switchSitting' and message.content.charName == mq.TLO.Me.Name() then
        dataHandler.boxes[message.content.charName].Sitting = mq.TLO.Me.Sitting()

        if dataHandler.boxes[message.content.charName].Sitting then
            mq.cmd('/stand')
        else
            mq.cmd('/sit')
        end

        -- Attack Button Message
    elseif message.content.id == 'updateMeleeTarget' and message.content.charName == mq.TLO.Me.Name() then
        dataHandler.boxes[message.content.charName].meleeTarget = message.content.meleeTarget
        -- Clear Target message
    elseif message.content.id == 'clearTarget' and message.content.charName == mq.TLO.Me.Name() then
        print("clearing Target")
        mq.cmd('/target clear')
    elseif message.content.id == 'updateSpellbar' and message.content.charName == mq.TLO.Me.Name() then
        print(message.content.gem, message.content.spellId)
        mq.cmdf('/memspell %i "%s"', message.content.gem, message.content.spellId)
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

msgHandler.DriverActor = actors.register('Driver', msgHandler.driverMessageHandler)
msgHandler.boxActor = actors.register('Box', msgHandler.boxMessageHandler)

return msgHandler

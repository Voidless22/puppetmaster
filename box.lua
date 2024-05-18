local mq = require('mq')
local actors = require('actors')
local msgHandler = require('msgHandler')
local Running = true
local dataHandler = require('dataHandler')
local boxName = mq.TLO.Me.Name()

local driverAddress = { mailbox = 'Driver', script = 'puppetmaster' }

local dataTable 

while not msgHandler.boxReady() do
    print('attempting to connect')
    msgHandler.boxActor:send(driverAddress, { id = 'Connect', boxName = boxName })
    mq.delay(100)
end
local function meleeRoutine()
    if mq.TLO.Target() ~= nil and mq.TLO.Target.ID() ~= mq.TLO.Me.ID() then
        mq.cmd('/attack on')
        if mq.TLO.Target.Distance() > mq.TLO.Target.MaxRangeTo() then
            mq.cmd('/nav target')
            while mq.TLO.Navigation.Active() do mq.delay(10) end
        end

        mq.cmd('/face')
        mq.delay(100)
    end
end

local function mirrorTarget()
    if mq.TLO.Group.MainAssist.ID() ~= nil and not (mq.TLO.Group.MainAssist.OtherZone() or mq.TLO.Group.MainAssist.Offline() or mq.TLO.Group.MainAssist.Name() == mq.TLO.Me.Name()) then
        if mq.TLO.Target.ID() ~= mq.TLO.Me.GroupAssistTarget.ID() then
            mq.TLO.Me.GroupAssistTarget.DoTarget()
        end
    end
end

local function doChase()
    if mq.TLO.Group.MainAssist.ID() ~= nil and not (mq.TLO.Group.MainAssist.OtherZone() or mq.TLO.Group.MainAssist.Offline() or mq.TLO.Group.MainAssist() == mq.TLO.Me.Name())
    then
        if not (mq.TLO.Group.MainAssist.OtherZone() or mq.TLO.Group.MainAssist.Offline() or mq.TLO.Group.MainAssist() == mq.TLO.Me.Name()) and
            mq.TLO.Group.MainAssist.Distance() > 20 and not mq.TLO.Me.Casting() and not dataTable.meleeTarget then
            mq.cmdf("/squelch /nav id %i", mq.TLO.Group.MainAssist.ID())
            while mq.TLO.Navigation.Active() do
                mq.delay(50)
            end
        end
    end
end

local function meleeHandler()
    if mq.TLO.Target.ID() == 0 or mq.TLO.Target.Dead() then
        dataTable.meleeTarget = false
        msgHandler.boxActor:send(driverAddress,
            { id = 'updateMeleeTarget', charName = mq.TLO.Me.Name(), meleeTarget = dataTable.meleeTarget })
        mq.cmd('/attack off')
    else
        meleeRoutine()
    end
end
if mq.TLO.Me.Combat() and not dataTable.meleeTarget then
    mq.cmd('/attack off')
end



local function main()
    while Running do
        if dataTable.chaseToggle then doChase() end
        if dataTable.followMATarget then mirrorTarget() end
        if dataTable.meleeTarget then meleeHandler() end
        mq.delay(50)
        dataHandler.UpdateData(mq.TLO.Me.Name())
        msgHandler.boxActor:send(driverAddress,
            { id = "UpdatedData", boxName = boxName, boxData = dataHandler.GetData(boxName) })
    end
end

dataHandler.AddNewCharacter(mq.TLO.Me.Name())
dataHandler.InitializeData(mq.TLO.Me.Name())
dataTable =  dataHandler.boxes[mq.TLO.Me.Name()]

msgHandler.boxActor:send(driverAddress, { id = "UpdatedData", boxName = boxName, boxData = dataHandler.GetData(boxName) })
main()

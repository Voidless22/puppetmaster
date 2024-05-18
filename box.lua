local mq = require('mq')
local actors = require('actors')
local msgHandler = require('msgHandler')
local Running = true
local dataHandler = require('dataHandler')
local boxName = mq.TLO.Me.Name()

local boxActor = actors.register('Box', msgHandler.boxMessageHandler)
local driverAddress = { mailbox = 'Driver', script = 'puppetmaster' }


while not msgHandler.boxReady() do
    print('attempting to connect')
    boxActor:send(driverAddress, { id = 'Connect', boxName = boxName })
    mq.delay(100)
end

local function main()
    while Running do
        mq.delay(500)
        dataHandler.UpdateData(mq.TLO.Me.Name())
        boxActor:send(driverAddress, { id = "UpdatedData", boxName = boxName, boxData = dataHandler.GetData(boxName) })
    end
end

dataHandler.AddNewCharacter(mq.TLO.Me.Name())
dataHandler.InitializeData(mq.TLO.Me.Name())
boxActor:send(driverAddress, { id = "UpdatedData", boxName = boxName, boxData = dataHandler.GetData(boxName) })
main()

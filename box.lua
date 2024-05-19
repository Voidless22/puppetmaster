local mq            = require('mq')
local actors        = require('actors')
local msgHandler    = require('msgHandler')
local utils         = require('utils')
local Running       = true
local dataHandler   = require('dataHandler')
local boxName       = mq.TLO.Me.Name()


local dataTable

while not msgHandler.boxReady() do
    print('attempting to connect')
    msgHandler.boxActor:send(msgHandler.driverAddress, { id = 'Connect', boxName = boxName })
    mq.delay(100)
end

local function main()
    while Running do
        if dataTable.chaseToggle then utils.doChase() end
        if dataTable.followMATarget then utils.mirrorTarget() end
        if dataTable.meleeTarget then utils.meleeHandler() end
        if mq.TLO.Me.Combat() and not dataTable.meleeTarget then
            mq.cmd('/attack off')
        end
        mq.delay(50)
        dataHandler.UpdateData(mq.TLO.Me.Name())
        msgHandler.boxActor:send(msgHandler.driverAddress,
            { id = "UpdatedData", boxName = boxName, boxData = dataHandler.GetData(boxName) })
    end
end

dataHandler.AddNewCharacter(mq.TLO.Me.Name())
dataHandler.InitializeData(mq.TLO.Me.Name())
dataTable = dataHandler.boxes[mq.TLO.Me.Name()]

msgHandler.boxActor:send(msgHandler.driverAddress, { id = "UpdatedData", boxName = boxName, boxData = dataHandler.GetData(boxName) })
main()

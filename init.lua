local mq = require('mq')
local imgui = require('ImGui')
local actors = require('actors')
local msgHandler = require('msgHandler')
local gui = require('gui')
local running = true

local driverActor = actors.register('Driver', msgHandler.driverMessageHandler)
local boxAddress = {mailbox='Box',script='puppetmaster/box'}
driverActor:send(boxAddress, {id='Connect'})

mq.imgui.init('Puppetmaster', gui.guiLoop)

local function updateBoxData()
driverActor:send(boxAddress, {id='UpdateData'})
end


local function main()
    while running do
        mq.delay(100)
    end
end
mq.bind('/updatedata', updateBoxData)
main()



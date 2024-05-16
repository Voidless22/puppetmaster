local mq = require('mq')
local imgui = require('ImGui')
local actors = require('actors')
local msgHandler = require('msgHandler')
local gui = require('gui')
local dataHandler = require('dataHandler')
local running = true
DebugMode = true
Settings = {
    OpenSpellbar = {},
    ShowSpellbar = {},
    OpenGroup = {},
    ShowGroup = {},
    OpenXTarget = {},
    ShowXTarget = {},
    OpenTarget = {},
    ShowTarget = {},
    OpenPet = {},
    ShowPet = {},
    OpenDash = {},
    ShowDash = {},
    OpenBuffs = {},
    ShowBuffs = {},
    OpenLoadout = {},
    ShowLoadout = {},

}
OpenSettings = false
ShowSettings = false

DriverActor = actors.register('Driver', msgHandler.driverMessageHandler)

local boxAddress = { mailbox = 'Box', script = 'puppetmaster/box' }
DriverActor:send(boxAddress, { id = 'Connect' })

mq.imgui.init('Puppetmaster', gui.guiLoop)

local function updateBoxData()
    DriverActor:send(boxAddress, { id = 'UpdateData' })
end


local function main()
    while running do
        mq.delay(100)
    end
end
dataHandler.AddNewCharacter(mq.TLO.Me.Name())
for index, value in pairs(Settings) do
    if not Settings[index][mq.TLO.Me.Name()] then
        Settings[index][mq.TLO.Me.Name()] = false
    end
    for charName, value in pairs(dataHandler.boxes) do
        if not Settings[index][charName] then
            Settings[index][mq.TLO.Me.Name()] = false
        end
    end
end
dataHandler.UpdateData(mq.TLO.Me.Name())
mq.bind('/pmsettings', function() OpenSettings = not OpenSettings end)
mq.bind('/updatedata', updateBoxData)
main()

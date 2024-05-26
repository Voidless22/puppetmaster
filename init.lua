local mq = require('mq')
local imgui = require('ImGui')
local actors = require('actors')
local msgHandler = require('msgHandler')
local gui = require('gui')
local dataHandler = require('dataHandler')
local utils = require('utils')
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
    OpenPlayer = {},
    ShowPlayer= {},

}


utils.driverActor:send(msgHandler.boxAddress, { id = 'Connect' })


local function updateBoxData()
    utils.driverActor:send(msgHandler.boxAddress, { id = 'UpdateData' })
end


local function main()
    while running do
        mq.delay(50)
        dataHandler.UpdateData(mq.TLO.Me.Name())

    end
end
dataHandler.AddNewCharacter(mq.TLO.Me.Name())
for index, value in pairs(Settings) do
    if  Settings[index][mq.TLO.Me.Name()] == nil then
        Settings[index][mq.TLO.Me.Name()] = false
    end
    for charName, value in pairs(dataHandler.boxes) do
        if  Settings[index][charName] == nil then
            Settings[index][mq.TLO.Me.Name()] = false
        end
    end
end
local settingsFile, err = loadfile(mq.configDir .. '/' .. 'PMSettings.lua')
if err then
    for index, value in pairs(Settings) do
        if not Settings[index][mq.TLO.Me.Name()] then
            Settings[index][mq.TLO.Me.Name()] = false
        end
    end
    mq.pickle('PMSettings.lua', Settings)
elseif settingsFile then
    local fileData = settingsFile()
    for settingName, value in pairs(Settings) do
        if fileData[settingName] == nil or fileData[settingName][mq.TLO.Me.Name()] == nil then
            Settings[settingName][mq.TLO.Me.Name()] = false
            mq.pickle('PMSettings.lua', Settings)
        else
            Settings[settingName][mq.TLO.Me.Name()] = fileData[settingName][mq.TLO.Me.Name()]
        end
    end
end
dataHandler.InitializeData(mq.TLO.Me.Name())
mq.bind('/pmsettings', function() OpenSettings = not OpenSettings end)
mq.bind('/updatedata', updateBoxData)
mq.imgui.init('Puppetmaster', gui.guiLoop)

main()

local mq         = require('mq')
local ImGui      = require('ImGui')
local actors     = require('actors')
local gui        = require('gui/gui')
local utils      = require('utils')
local msgHandler = require('msgHandler')
local Write      = require('knightlinc/Write')
local args       = { ... }
local Running    = true
local Debug      = true
local isHost     = false
local isBox      = false

Write.prefix     = 'PuppetMaster'



local hostActor = actors.register('Host', msgHandler.hostMessageHandler)

if Debug then
    Write.loglevel = 'debug'
end

mq.imgui.init('PuppetMaster', gui.guiLoop)


local function main()
    while Running do
        mq.delay(100)
    end
end

main()

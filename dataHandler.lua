local mq = require('mq')
local actors = require('actors')

local dataHandler = {}

dataHandler.boxes = {}

function dataHandler.AddNewBox(boxName)
    if not dataHandler.boxes[boxName] then
        dataHandler.boxes[boxName] = { stats = {}, spells = {} }
        printf('DataHandler:Box Entry created in box table: %s', boxName)
    else
        printf('DataHandler:Box Entry creation attempted, but already exists.')
    end
end


return dataHandler

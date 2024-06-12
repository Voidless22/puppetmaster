local mq          = require('mq')
local actors      = require('actors')
local msgHandler  = require('msgHandler')
local utils       = require('utils')
local Running     = true
local dataHandler = require('dataHandler')
local boxName     = mq.TLO.Me.Name()


local dataTable

while not msgHandler.boxReady() do
    print('attempting to connect')
    utils.boxActor:send(msgHandler.driverAddress, { id = 'Connect', boxName = boxName })
    mq.delay(100)
end
local function addNewSpell(line, arg1)
    print('Event triggered')
    local spellFound = false
    for index, value in ipairs(dataHandler.boxes[mq.TLO.Me.Name()].Spellbook) do
        if value.name == arg1 then
            spellFound = true
        end
    end
    if not spellFound then
        local spellID = mq.TLO.Spell(arg1).ID()
        local spellCategory = mq.TLO.Spell(spellID).Category()
        local spellSubcategory = mq.TLO.Spell(spellID).Subcategory()
        local spellLevel = mq.TLO.Spell(spellID).Level()
        local spellName = arg1

        table.insert(dataHandler.boxes[mq.TLO.Me.Name()].Spellbook,
            {
                category = spellCategory,
                subcategory = spellSubcategory,
                level = spellLevel,
                name = spellName,
                id = spellID
            })
    end
end

local function handleMessageQueue()
    local messageQueue = dataHandler.GetMessageQueue()
    for index, value in pairs(messageQueue) do
        local cBox = dataHandler.GetData(mq.TLO.Me.Name())
        local dataIndex = messageQueue[index].index
        local dataSubIndex = messageQueue[index].subtable
        local payload
        if dataSubIndex then
            payload = {
                id = 'UpdatedData',
                boxName = mq.TLO.Me.Name(),
                dataIndex = dataIndex,
                dataSubIndex = dataSubIndex,
                boxData = cBox[dataIndex][dataSubIndex]
            }
        else
            payload = {
                id = 'UpdatedData',
                boxName = mq.TLO.Me.Name(),
                dataIndex = dataIndex,
                boxData = cBox[dataIndex]
            }
        end
        utils.boxActor:send(msgHandler.driverAddress, payload)
        dataHandler.SetMessageQueue(index, 0)
    end
end


local function main()
    while Running do
        handleMessageQueue()
        if dataTable.chaseToggle then utils.doChase() end
        if dataTable.followMATarget then utils.mirrorTarget() end
        if dataTable.meleeTarget then utils.meleeHandler() end
        if mq.TLO.Me.Combat() and not dataTable.meleeTarget then
            mq.cmd('/attack off')
        end
        mq.delay(100)
        mq.doevents()
        dataHandler.UpdateData(mq.TLO.Me.Name())

    end
end

dataHandler.AddNewCharacter(mq.TLO.Me.Name())
dataHandler.InitializeData(mq.TLO.Me.Name())
dataTable = dataHandler.boxes[mq.TLO.Me.Name()]
dataHandler.UpdateData(mq.TLO.Me.Name())
mq.event("NewSpellScribed", "You have finished scribing #1#.", addNewSpell)
utils.boxActor:send(msgHandler.driverAddress,
    { id = "InitData", boxName = boxName, boxData = dataHandler.GetData(boxName) })
main()

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

local SpellSorter = function(a, b)
    if a[1] < b[1] then
        return false
    elseif b[1] < a[1] then
        return true
    else
        return false
    end
end
local previousSpellTable = { categories = {} }
local currentSpellTable = { categories = {} }
local function buildSpellTable()
    local sendUpdate = false
    for i = 1, 720 do
        if mq.TLO.Me.Book(i).ID() ~= nil then
            local spellID = mq.TLO.Me.Book(i).ID()
            local spellCategory = mq.TLO.Spell(spellID).Category()
            local spellSubcategory = mq.TLO.Spell(spellID).Subcategory()
            if not previousSpellTable[spellCategory] then
                previousSpellTable[spellCategory] = { subcategories = {} }
                table.insert(previousSpellTable.categories, spellCategory)
            end
            if not previousSpellTable[spellCategory][spellSubcategory] then
                previousSpellTable[spellCategory][spellSubcategory] = {}
                table.insert(previousSpellTable[spellCategory].subcategories, spellSubcategory)
            end
            table.insert(previousSpellTable[spellCategory][spellSubcategory],
                { mq.TLO.Spell(spellID).Level(), mq.TLO.Spell(spellID).Name() })
            sendUpdate = true
        end
    end
    if sendUpdate then
        table.sort(previousSpellTable.categories)
        for category, subcategories in pairs(previousSpellTable) do
            if category ~= 'categories' then
                table.sort(previousSpellTable[category].subcategories)
                for subcategory, subcatspells in pairs(subcategories) do
                    if subcategory ~= 'subcategories' then
                        table.sort(subcatspells, SpellSorter)
                    end
                end
            end
        end

        for _, category in ipairs(previousSpellTable['categories']) do
            for _, subcategory in ipairs(previousSpellTable[category]['subcategories']) do
                for _, spell in ipairs(previousSpellTable[category][subcategory]) do
                    printf(' %s: Spell: %s Level: %i in Category: %s under Subcategory: %s', mq.TLO.Me.Name(), spell[2],
                        spell[1], category, subcategory)
                end
            end
        end
        msgHandler.boxActor:send(msgHandler.boxAddress,
            { id = 'updateSpellTable', charName = mq.TLO.Me.Name(), spellTable = previousSpellTable })
    end
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
dataTable = dataHandler.boxes[mq.TLO.Me.Name()]
buildSpellTable()

msgHandler.boxActor:send(driverAddress, { id = "UpdatedData", boxName = boxName, boxData = dataHandler.GetData(boxName) })
main()

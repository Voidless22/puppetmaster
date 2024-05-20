local mq = require('mq')
--local dataHandler = require('dataHandler')
local utils = {}
--local dataTable = dataHandler.boxes[mq.TLO.Me.Name()]

local function SpellSorter(a, b)
    if a[1] < b[1] then
        return false
    elseif b[1] < a[1] then
        return true
    else
        return false
    end
end

local spellTable = {}
local spellCategories = {}
local spellSubCategories = {}

function utils.buildSpellTable()
    for i = 1, 720 do
        if mq.TLO.Me.Book(i).ID() then
            local spellID = mq.TLO.Me.Book(i).ID()
            local spellCategory = mq.TLO.Spell(spellID).Category()
            local spellSubcategory = mq.TLO.Spell(spellID).Subcategory()
            local spellLevel = mq.TLO.Spell(spellID).Level()
            local spellName = mq.TLO.Spell(spellID).Name()

            table.insert(spellTable, {category=spellCategory, subcategory=spellSubcategory, level = spellLevel, name=spellName, id=spellID})
        end
    end
    for index, value in ipairs(spellTable) do
        local spellEntry = spellTable[index]
        printf('Index: %i, Category: %s Subcategory: %s Level: %i Name:%s ID:%i',index,spellEntry.category, spellEntry.subcategory, spellEntry.level, spellEntry.name, spellEntry.id)
    end
    return spellTable
end

function utils.mirrorTarget()
    if mq.TLO.Group.MainAssist.ID() ~= nil and not (mq.TLO.Group.MainAssist.OtherZone() or mq.TLO.Group.MainAssist.Offline() or mq.TLO.Group.MainAssist.Name() == mq.TLO.Me.Name()) then
        if mq.TLO.Target.ID() ~= mq.TLO.Me.GroupAssistTarget.ID() then
            mq.TLO.Me.GroupAssistTarget.DoTarget()
        end
    end
end

function utils.doChase()
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

function utils.meleeHandler()
    if mq.TLO.Target.ID() == 0 or mq.TLO.Target.Dead() then
        dataTable.meleeTarget = false
        msgHandler.boxActor:send(msgHandler.driverAddress,
            { id = 'updateMeleeTarget', charName = mq.TLO.Me.Name(), meleeTarget = dataTable.meleeTarget })
        mq.cmd('/attack off')
    else
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
end

return utils

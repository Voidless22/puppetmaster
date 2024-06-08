local mq = require('mq')

local dataHandler = {}

dataHandler.boxes = {}
dataHandler.updateQueue = {}
dataHandler.messageQueue = {}
local spellTable = {}
local function buildSpellTable()
    for i = 1, 720 do
        if mq.TLO.Me.Book(i).ID() then
            local spellID = mq.TLO.Me.Book(i).ID()
            local spellCategory = mq.TLO.Spell(spellID).Category()
            local spellSubcategory = mq.TLO.Spell(spellID).Subcategory()
            local spellLevel = mq.TLO.Spell(spellID).Level()
            local spellName = mq.TLO.Spell(spellID).Name()

            table.insert(spellTable,
                {
                    category = spellCategory,
                    subcategory = spellSubcategory,
                    level = spellLevel,
                    name = spellName,
                    id = spellID
                })
        end
    end

    return spellTable
end
local function returnIsCasting()
    if mq.TLO.Me.Casting() then
        return true
    else
        return false
    end
end

local function returnSpellCD(gem)
    if not mq.TLO.Me.SpellReady(gem)() then
        return mq.TLO.Me.Gem(gem).RecastTime()
    else
        return 0
    end
end
function dataHandler.AddNewCharacter(name)
    if not dataHandler.boxes[name] then
        dataHandler.boxes[name] = {}

        printf('\agData Manager: \awEntry created in Character Data table: \at%s', name)
    else
        printf('\agData Manager: \arCharacter Data Entry creation attempted, but already exists.')
    end
end
function dataHandler.InitializeData(boxName)
    dataHandler.boxes[boxName] = {}
    local cBox = dataHandler.boxes[boxName]
    cBox.PctHP = mq.TLO.Me.PctHPs()
    cBox.PctMana = mq.TLO.Me.PctMana()
    cBox.BuffIds = {}
    cBox.BuffDurations = {}
    cBox.Spellbar = {}
    cBox.SpellCooldowns = {}
    cBox.Group = {}
    cBox.Target = { id = mq.TLO.Target.ID(), ConColor = mq.TLO.Target.ConColor(), AggroPct = mq.TLO.Target.PctAggro() }
    cBox.TargetBuffs = {}
    cBox.Spellbook = buildSpellTable()
    cBox.CombatAbilities = {}
    cBox.PetFollow = true
    cBox.PetTaunt = mq.TLO.Me.Pet.Taunt()
    cBox.followMATarget = false
    cBox.chaseToggle = false
    cBox.meleeTarget = false
    cBox.Sitting = mq.TLO.Me.Sitting()
    cBox.isCasting = false
    cBox.lastCastGem = 0
    cBox.CombatState = mq.TLO.Me.CombatState()
    cBox.CastTimeLeft = mq.TLO.Me.CastTimeLeft.Seconds()
    cBox.xtIDs = {}
    cBox.xtConColors = {}
    cBox.xtAggroPcts = {}
end
function dataHandler.GetData(boxName)
    if dataHandler.boxes[boxName] then
        return dataHandler.boxes[boxName]
    end
end

function dataHandler.GetMessageQueue()
    return dataHandler.messageQueue
end

function dataHandler.SetMessageQueue(index, data)
    if data == 0 then
        dataHandler.messageQueue[index] = nil
    else
        dataHandler.messageQueue[index] = data
    end
end
function dataHandler.UpdateCheck(dataIndex, prevData, currentData, subIndex)
    if dataHandler.updateQueue[dataIndex] == nil then
        dataHandler.updateQueue[dataIndex] = {}
    end
    -- data the same? Clear the Queue entry
    if prevData == currentData and subIndex == nil then
        dataHandler.updateQueue[dataIndex] = nil
    elseif prevData == currentData and subIndex ~= nil then
        dataHandler.updateQueue[dataIndex][subIndex] = nil
    elseif subIndex == nil then
        dataHandler.updateQueue[dataIndex] = currentData
        return
    elseif subIndex ~= nil then
        dataHandler.updateQueue[dataIndex][subIndex] = currentData
        return
    end
end

function dataHandler.ProcessQueue(boxName)
    local cBox = dataHandler.boxes[boxName]
    for index, value in pairs(dataHandler.updateQueue) do
        if type(value) == "table" then
            for subtable, data in pairs(value) do
                if cBox[index] then
                    cBox[index][subtable] = data
                    table.insert(dataHandler.messageQueue, { index = index, subtable = subtable })
                    printf("Updating %s: Subtable: %s value:%s", index, subtable, data)
                end
            end
        else
            printf('Updating: %s to %s', index, value)
            cBox[index] = value
            table.insert(dataHandler.messageQueue, { index = index })
        end
    end
end

function dataHandler.UpdateSpellbar(boxName)
    local cBox = dataHandler.boxes[boxName]
    local gemCount = 8 + (mq.TLO.Me.AltAbility("Mnemonic Retention").Rank() or 0)
    for gem = 1, gemCount do
        dataHandler.UpdateCheck("Spellbar", cBox.Spellbar[gem], (mq.TLO.Me.Gem(gem).ID() or 0), gem)
        dataHandler.UpdateCheck("SpellCooldowns", cBox.SpellCooldowns[gem], returnSpellCD(gem), gem)
    end
end

function dataHandler.UpdateBuffs(boxName)
    local cBox = dataHandler.boxes[boxName]
    for i = 1, mq.TLO.Me.MaxBuffSlots() do
        dataHandler.UpdateCheck("BuffIds", cBox.BuffIds[i], (mq.TLO.Me.Buff(i).Spell.ID() or 0), i)
        dataHandler.UpdateCheck("BuffDurations", cBox.BuffDurations[i], (mq.TLO.Me.Buff(i).Duration.TimeHMS() or 0), i)
    end
end

function dataHandler.UpdateGroup(boxName)
    local cBox = dataHandler.boxes[boxName]
    for i = 0, mq.TLO.Me.GroupSize() do
        dataHandler.UpdateCheck("Group", cBox.Group[i], mq.TLO.Group.Member(i).Name(), i)
    end
end

function dataHandler.UpdateXTarget(boxName)
    local cBox = dataHandler.boxes[boxName]
    for i = 1, mq.TLO.Me.XTargetSlots() do
        dataHandler.UpdateCheck("xtIDs", cBox.xtIDs[i], (mq.TLO.Me.XTarget(i).ID() or 0), i)
        dataHandler.UpdateCheck("xtConColors", cBox.xtConColors[i], (mq.TLO.Me.XTarget(i).ConColor() or 0), i)
        dataHandler.UpdateCheck("xtAggroPcts", cBox.xtAggroPcts[i], (mq.TLO.Me.XTarget(i).PctAggro() or 0), i)
    end
end

function dataHandler.UpdateTargetBuffs(boxName)
    local cBox = dataHandler.boxes[boxName]

    for i = 1, (mq.TLO.Target.BuffCount() or 1) do
        dataHandler.UpdateCheck("TargetBuffs", cBox.TargetBuffs[i], mq.TLO.Target.Buff(i).SpellID(), i)
    end
end

function dataHandler.UpdateData(boxName)
    local cBox = dataHandler.boxes[boxName]
    dataHandler.UpdateCheck("Sitting", cBox.Sitting, mq.TLO.Me.Sitting())
    dataHandler.UpdateCheck("isCasting", cBox.isCasting, returnIsCasting())
    dataHandler.UpdateCheck("PctHP", cBox.PctHP, mq.TLO.Me.PctHPs())
    dataHandler.UpdateCheck("PctMana", cBox.PctMana, mq.TLO.Me.PctMana())
    dataHandler.UpdateCheck("PctEnd", cBox.PctEnd, mq.TLO.Me.PctEndurance())
    dataHandler.UpdateCheck("CombatState", cBox.CombatState, mq.TLO.Me.CombatState())
    dataHandler.UpdateCheck("Target", cBox.Target.id, (mq.TLO.Target.ID() or 0), "id")
    dataHandler.UpdateCheck("Target", cBox.Target.ConColor, (mq.TLO.Target.ConColor() or 0), "ConColor")
    dataHandler.UpdateCheck("Target", cBox.Target.AggroPct, (mq.TLO.Target.PctAggro() or 0), "AggroPct")
    dataHandler.UpdateCheck("CastTimeLeft", cBox.CastTimeLeft, mq.TLO.Me.CastTimeLeft.Seconds())
    dataHandler.UpdateSpellbar(boxName)
    dataHandler.UpdateGroup(boxName)
    dataHandler.UpdateXTarget(boxName)
    dataHandler.UpdateBuffs(boxName)
    dataHandler.UpdateTargetBuffs(boxName)
    dataHandler.ProcessQueue(boxName)
end

return dataHandler

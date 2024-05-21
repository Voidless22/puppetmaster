local mq = require('mq')
local actors = require('actors')

local dataHandler = {}

dataHandler.boxes = {}

local spellTable = {}
local spellCategories = {}
local spellSubCategories = {}

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
                    id =
                        spellID
                })
        end
    end
    for index, value in ipairs(spellTable) do
        local spellEntry = spellTable[index]
        printf('Index: %i, Category: %s Subcategory: %s Level: %i Name:%s ID:%i', index, spellEntry.category,
            spellEntry.subcategory, spellEntry.level, spellEntry.name, spellEntry.id)
    end
    return spellTable
end

function dataHandler.AddNewCharacter(charName)
    if not dataHandler.boxes[charName] then
        dataHandler.boxes[charName] = {}

        printf('\agDataHandler: \awEntry created in Character Data table: \at%s', charName)
    else
        printf('\agDataHandler: \arCharacter Data Entry creation attempted, but already exists.')
    end
end

function dataHandler.GetData(charName)
    if dataHandler.boxes[charName] then
        return dataHandler.boxes[charName]
    end
end

local function updateBuffs(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    for index = 1, mq.TLO.Me.MaxBuffSlots() do
        local buffFound = false
        if mq.TLO.Me.Buff(index)() ~= nil then
            for _, value in ipairs(currentBoxIndex.Buffs) do
                if value == mq.TLO.Me.Buff(index).Spell.ID() then
                    buffFound = true
                end
            end
            if not buffFound then
                currentBoxIndex.Buffs[index] = mq.TLO.Me.Buff(index).Spell.ID()
            end
        else
            currentBoxIndex.Buffs[index] = 0
        end
    end
end

local function updateTargetBuffs(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    local targetBuffCount = mq.TLO.Target.BuffCount()
    if targetBuffCount == 0 then
        for i = 0, #currentBoxIndex.targetBuffs do
            currentBoxIndex.targetBuffs[i] = nil
        end
    elseif mq.TLO.Target.BuffCount() and mq.TLO.Target.ID() ~= 0 then
        for i = 0, targetBuffCount do
            local buffFound = false
            if mq.TLO.Target.Buff(i).SpellID() ~= nil and currentBoxIndex.targetBuffs[i] ~= mq.TLO.Target.Buff(i).SpellID() then
                for _, value in pairs(currentBoxIndex.targetBuffs) do
                    if value == mq.TLO.Target.Buff(i).SpellID() then
                        buffFound = true
                    end
                end
            end
            if not buffFound then
                currentBoxIndex.targetBuffs[i] = mq.TLO.Target.Buff(i).SpellID()
            end
        end
    end
end

local function updateSpellbar(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    for gem = 1, mq.TLO.Me.NumGems() do
        if mq.TLO.Me.Gem(gem).ID() == nil then
            currentBoxIndex.Spellbar[gem] = 0
        else
            currentBoxIndex.Spellbar[gem] = mq.TLO.Me.Gem(gem).ID()
        end
    end
end
local function updateGroup(boxName)
    local foundSelf = false
    local currentBoxIndex = dataHandler.boxes[boxName]
    for member = 1, mq.TLO.Me.GroupSize() do
        currentBoxIndex.Group[member] = mq.TLO.Group.Member(member).ID()
    end
    for index, value in ipairs(currentBoxIndex.Group) do
        if value == mq.TLO.Me.ID() then
            foundSelf = true
        end
    end
    if not foundSelf then
        table.insert(currentBoxIndex.Group, mq.TLO.Me.ID())
    end
end

local function updateXTarget(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    for i = 1, mq.TLO.Me.XTargetSlots() do
        if mq.TLO.Me.XTarget(i).ID() == nil or mq.TLO.Me.XTarget(i).ID() == 0 then
            currentBoxIndex.XTarget[i] = 'Empty'
        end
        if mq.TLO.Me.XTarget(i).ID() ~= nil and mq.TLO.Me.XTarget(i).ID() ~= 0 then
            currentBoxIndex.XTarget[i] = mq.TLO.Me.XTarget(i).ID()
        end
    end
end

local function updatePet(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    -- No Pet
    if mq.TLO.Me.Pet() == "NO PET" then
        currentBoxIndex.Pet = "NO PET"
    end
    -- Pet Summoned
    if mq.TLO.Me.Pet() ~= 'NO PET' then
        currentBoxIndex.Pet = mq.TLO.Spawn(mq.TLO.Me.Pet()).ID()
        -- in combat
        if mq.TLO.Me.Pet.Combat() ~= currentBoxIndex.PetInCombat then
            currentBoxIndex.PetInCombat = mq.TLO.Me.Pet.Combat()
        end
        -- Target
        if mq.TLO.Me.Pet.Target.ID() == 0 or mq.TLO.Me.Pet.Target.Dead() then
            currentBoxIndex.PetTarget = 'Empty'
        else
            currentBoxIndex.PetTarget = mq.TLO.Me.Pet.Target.ID()
        end
        -- Taunt
        currentBoxIndex.PetTaunt = mq.TLO.Me.Pet.Taunt()
    end
end

function dataHandler.InitializeData(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]

    currentBoxIndex.PctHP = mq.TLO.Me.PctHPs()
    currentBoxIndex.PctMana = mq.TLO.Me.PctMana()
    currentBoxIndex.PctEnd = mq.TLO.Me.PctEndurance()
    currentBoxIndex.Level = mq.TLO.Me.Level()
    currentBoxIndex.Class = mq.TLO.Me.Class()
    currentBoxIndex.Race = mq.TLO.Me.Race()
    if not currentBoxIndex.targetBuffs then currentBoxIndex.targetBuffs = {} end
    if not currentBoxIndex.Buffs then currentBoxIndex.Buffs = {} end
    if not currentBoxIndex.XTarget then currentBoxIndex.XTarget = {} end
    if not currentBoxIndex.Spellbar then currentBoxIndex.Spellbar = {} end
    if not currentBoxIndex.Group then currentBoxIndex.Group = {} end
    currentBoxIndex.targetID = mq.TLO.Target.ID()
    currentBoxIndex.Spellbook = buildSpellTable()
    currentBoxIndex.CombatAbilities = {}
    currentBoxIndex.PetFollow = true
    currentBoxIndex.PetTaunt = mq.TLO.Me.Pet.Taunt()
    currentBoxIndex.followMATarget = false
    currentBoxIndex.chaseToggle = false
    currentBoxIndex.meleeTarget = false
    currentBoxIndex.Sitting = mq.TLO.Me.Sitting()
    currentBoxIndex.isCasting = mq.TLO.Me.Casting()
    currentBoxIndex.lastCastGem = 0
    currentBoxIndex.CombatState = mq.TLO.Me.CombatState()
end

function dataHandler.UpdateData(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    currentBoxIndex.Sitting = mq.TLO.Me.Sitting()
    currentBoxIndex.isCasting = mq.TLO.Me.Casting()
    currentBoxIndex.PctHP = mq.TLO.Me.PctHPs()
    currentBoxIndex.PctMana = mq.TLO.Me.PctMana()
    currentBoxIndex.PctEnd = mq.TLO.Me.PctEndurance()
    currentBoxIndex.CombatState = mq.TLO.Me.CombatState()
    updateBuffs(boxName)
    currentBoxIndex.targetID = mq.TLO.Target.ID()
    updateTargetBuffs(boxName)
    updateSpellbar(boxName)
    updateGroup(boxName)
    updateXTarget(boxName)
    updatePet(boxName)
end

return dataHandler

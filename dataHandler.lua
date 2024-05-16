local mq = require('mq')
local actors = require('actors')

local dataHandler = {}

dataHandler.boxes = {}

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
    local buffCount = mq.TLO.Me.BuffCount()
    local currentBoxIndex = dataHandler.boxes[boxName]
    if buffCount == 0 then
        for i = 0, #currentBoxIndex.Buffs do
            currentBoxIndex.Buffs[i] = nil
        end
    end
    for index = 1, mq.TLO.Me.MaxBuffSlots() do
        local buffFound = false
        if mq.TLO.Me.Buff(index).Spell.ID() ~= nil then
            for _, value in pairs(currentBoxIndex.Buffs) do
                if value == mq.TLO.Me.Buff(index).Spell.ID() then
                    buffFound = true
                end
            end
        end
        if not buffFound then
            currentBoxIndex.Buffs[index] = mq.TLO.Me.Buff(index).Spell.ID()
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
    elseif mq.TLO.Target.BuffCount() > 0 and mq.TLO.Target.ID() ~= 0 then
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
        currentBoxIndex.Spellbar[gem] = mq.TLO.Me.Gem(gem).ID()
    end
end
local function updateGroup(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    for member = 0, mq.TLO.Me.GroupSize() do
        currentBoxIndex.Group[member] = mq.TLO.Group.Member(member).ID()
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


function dataHandler.UpdateData(boxName)
    local currentBoxIndex = dataHandler.boxes[boxName]
    currentBoxIndex.Level = mq.TLO.Me.Level()
    currentBoxIndex.Class = mq.TLO.Me.Class()
    currentBoxIndex.Race = mq.TLO.Me.Race()
    currentBoxIndex.PctHP = mq.TLO.Me.PctHPs()
    currentBoxIndex.PctMana = mq.TLO.Me.PctMana()
    currentBoxIndex.PctEnd = mq.TLO.Me.PctEndurance()
    if not currentBoxIndex.targetBuffs then currentBoxIndex.targetBuffs = {} end
    if not currentBoxIndex.Buffs then currentBoxIndex.Buffs = {} end
    if not currentBoxIndex.XTarget then currentBoxIndex.XTarget = {} end
    if not currentBoxIndex.Spellbar then currentBoxIndex.Spellbar = {} end
    if not currentBoxIndex.Group then currentBoxIndex.Group = {} end
    
    updateBuffs(boxName)
    currentBoxIndex.targetID = mq.TLO.Target.ID()
    updateTargetBuffs(boxName)
    updateSpellbar(boxName)
    updateGroup(boxName)
    updateXTarget(boxName)
    currentBoxIndex.Spellbook = {}
    currentBoxIndex.CombatAbilities = {}
end

return dataHandler

local mq = require('mq')

local Utils = {}

function Utils.GetCurrentSpellbar()
    local cSpellbar = {}
    local gem = mq.TLO.Me.Gem
    for cGem = 1, mq.TLO.Me.NumGems() do
        if gem(cGem).ID() then
            cSpellbar[cGem] = gem(cGem).ID()
        else
            cSpellbar[cGem] = 'Empty'
        end
    end
    return cSpellbar
end

function Utils.UpdateStats()
    local hpPct = mq.TLO.Me.PctHPs()
    local manaPct = mq.TLO.Me.PctMana()
    local endPct = mq.TLO.Me.PctEndurance()
    local stats = { hpPct, manaPct, endPct }
    return stats
end

function Utils.UpdateGroup()
    local groupMembers = {}
    if mq.TLO.Group.GroupSize() ~= nil then
        for i = 0, mq.TLO.Group.GroupSize() do
            if mq.TLO.Group.Member(i).ID() then
                groupMembers[i] = mq.TLO.Group.Member(i).ID()
            end
        end
    end
    return groupMembers
end

function Utils.UpdateTarget()
    local myTarget = mq.TLO.Target
    local targetid
    local targetBuffs = {}
    if myTarget.ID() > 0 then
        targetid = myTarget.ID()
        if myTarget.BuffCount() > 0 then
            for i = 0, myTarget.BuffCount() do
                local buffFound = false
                if myTarget.Buff(i).SpellID() then
                    for _, value in ipairs(targetBuffs) do
                        if value == myTarget.Buff(i).SpellID() then
                            buffFound = true
                        end
                    end
                end
                if not buffFound then
                    targetBuffs[i] = myTarget.Buff(i).SpellID()
                end
            end
        end
    end
    return { targetid, targetBuffs }
end

function Utils.UpdateXTarget()
    local myXTarget = mq.TLO.Me.XTarget
    local xTargetSlots = mq.TLO.Me.XTargetSlots()
    local xTargetList = {}
    for i = 1, xTargetSlots do
        if myXTarget(i).ID() > 0 then
            xTargetList[i] = myXTarget(i).ID()
        end
    end
    return xTargetList
end

return Utils

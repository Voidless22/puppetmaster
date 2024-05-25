local mq = require('mq')
local dataHandler = require('dataHandler')
local utils = {}
local msgHandler = require('msgHandler')
local actors = require('actors')
local function SpellSorter(a, b)
    if a[1] < b[1] then
        return false
    elseif b[1] < a[1] then
        return true
    else
        return false
    end
end

local dataTable = dataHandler.boxes[mq.TLO.Me.Name()]
local colors = {
    ["Red"] = ImVec4(1, 0, 0, 1),
    ["Green"] = ImVec4(0, 1, 0, 1),
    ["Light Blue"] = ImVec4(0.3, 0.64, 1, 1),
    ["Blue"] = ImVec4(0.2,0.3, 1, 1),
    ["Yellow"] = ImVec4(1, 0.94, 0, 1),
    ["Grey"] = ImVec4(0.42,0.48,0.53,1)

}

function utils.Color(color, alpha)
    local c = colors[color]
    if c then
        return ImVec4(c.x, c.y, c.z, alpha or c.w)
    end
    printf("Color: %s doesn't exist.", color)
    return nil
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
            mq.TLO.Group.MainAssist.Distance() > 20 and not mq.TLO.Me.Casting() and not dataHandler.boxes[mq.TLO.Me.Name()].meleeTarget then
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
        utils.boxActor:send(msgHandler.driverAddress,
            { id = 'updateMeleeTarget', charName = mq.TLO.Me.Name(), meleeTarget = dataHandler.boxes[mq.TLO.Me.Name()]
            .meleeTarget })
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

utils.driverActor = actors.register('Driver', msgHandler.driverMessageHandler)
utils.boxActor = actors.register('Box', msgHandler.boxMessageHandler)



return utils

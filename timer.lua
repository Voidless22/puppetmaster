-- credit to aquietone for timer code, from https://github.com/aquietone/misclua/blob/main/timer.lua
local mq = require('mq')

---@class Timer
---@field expiration number #Time, in milliseconds, after which the timer expires.
---@field start_time number #Time since epoch, in milliseconds, when timer is counting from.
local Timer = {
    expiration = 0,
    start_time = 0,
}

---Initialize a new timer istance.
---@param expiration number @The number, in milliseconds, after which the timer will expire.
---@return Timer @The timer instance.
function Timer:new(expiration)
    local t = {
        start_time = mq.gettime(),
        expiration = expiration
    }
    setmetatable(t, self)
    self.__index = self
    return t
end

---Reset the start time value to the current time.
---@param to_value? number @The value to reset the timer to.
function  Timer:reset(to_value)
    self.start_time = to_value or mq.gettime()
end

---Check whether the specified timer has passed its expiration.
---@return boolean @Returns true if the timer has expired, otherwise false.
function Timer:timer_expired()
    return mq.gettime() - self.start_time > self.expiration
end

function  Timer:time_remaining()
        -- Convert milliseconds to total seconds
        local total_seconds = math.floor((self.expiration - (mq.gettime() - self.start_time)) / 1000)

        -- Calculate minutes
        local minutes = math.floor(total_seconds / 60)
    
        -- Calculate remaining seconds
        local seconds = total_seconds % 60
        local time = minutes .."m"..seconds.."s"
    
        return time
end

return Timer
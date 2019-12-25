local redisopt = require "redisopt"

local reddb = redisopt.default

local redismetadata = require "redismetadata"

local base_emails = {}

setmetatable(base_emails,{
    __index = function(t,eid)
        local info = reddb:hgetall("email:"..tostring(eid))
        info = redismetadata.email.info:decode(info)
        t[eid] = info
        return info
    end,
})


return base_emails
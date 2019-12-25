local log = require "log"
local redisopt = require "redisopt"
local channel = require "channel"
local redismetadata = require "redismetadata"

local reddb = redisopt.default


local onlineguid = setmetatable({},{
    __index = function(t,k)
        local guid = k
        local session = reddb:hgetall("player:online:guid:"..tostring(guid))
        if not session then
            return nil
        end

        session = redismetadata.player.online:decode(session)

        t[k] = session
        return session
end})

function onlineguid.send(guids,msgname,msg)
    msg = msg or {}
    local function guidsend(player_or_guid,msgname,msg)
        local guid = type(player_or_guid) == "table" and player_or_guid.guid or player_or_guid
        local s = onlineguid[guid]
        if not s or not s.gate then 
            -- log.warning("send2guid %d not online.",guid)
            return
        end
  
        channel.publish("gate."..s.gate,"client",guid,"proxy",msgname,msg)
    end

    if type(guids) == "number" then
        guidsend(guids,msgname,msg)
        return
    end

    for _,guid in pairs(guids) do
        guidsend(guid,msgname,msg)
    end
end

function onlineguid.control(player_or_guid,msgname,msg)
    local guid = type(player_or_guid) == "table" and player_or_guid.guid or player_or_guid
    local s = onlineguid[guid]
    if not s or not s.gate then 
        log.warning("control2guid %d not online.",guid)
        return
    end

    log.info("onlineguid.control %s %s %s",guid,msgname,msg)

    channel.publish("gate."..s.gate,"client",guid,"lua",msgname,msg)
end

function onlineguid.broadcast(msgname,msg)
    for guid,s in pairs(onlineguid) do
        channel.publish("gate."..s.gate,"client",guid,"proxy",msgname,msg)
    end
end

function onlineguid.broadcast_except(except,msgname,msg)
    except = type(except) == "number" and except or except.guid
    for guid,s in pairs(onlineguid) do
        if guid ~= except then
            channel.publish("gate."..s.gate,"client",guid,"proxy",msgname,msg)
        end
    end
end

return onlineguid
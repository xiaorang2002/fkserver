local redisopt = require "redisopt"
local table_template = require "game.lobby.table_template"

local reddb = redisopt.default


local club_table_template = {}


setmetatable(club_table_template,{
    __index = function(t,club_id)
        local ids = reddb:smembers(string.format("club:table_template:%d",club_id))
        local templates = {}
        for _,id in pairs(ids) do
            id = tonumber(id)
            templates[id] = table_template[id]
        end

        t[club_id] = templates
        
        return templates
    end
})


return club_table_template
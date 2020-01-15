local base_player = require "game.lobby.base_player"
local log = require "log"
local base_club = require "game.club.base_club"
local pb = require "pb_files"
local redisopt = require "redisopt"
local base_players = require "game.lobby.base_players"
local base_clubs = require "game.club.base_clubs"
local club_memeber = require "game.club.club_member"
local player_club = require "game.club.player_club"
local channel = require "channel"
local serviceconf = require "serviceconf"
local onlineguid = require "netguidopt"
local club_table = require "game.club.club_table"
local club_table_template = require "game.club.club_table_template"
local player_request = require "game.club.player_request"
local base_request = require "game.club.base_request"
local club_game_type = require "game.club.club_game_type"
local base_private_table = require "game.lobby.base_private_table"
local club_role = require "game.club.club_role"
local table_template = require "game.lobby.table_template"
local json = require "cjson"
local enum = require "pb_enums"
require "functions"

local g_room = g_room

local reddb = redisopt.default

local club_op = {
    ADD_TO_BLACK = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","ADD_TO_BLACK"),
    REMOVE_TO_BLACK    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","REMOVE_TO_BLACK"),
    ADD_ADMIN    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","ADD_ADMIN"),
    REMOVE_ADMIN    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","REMOVE_ADMIN"),
    REMOVE_PLAYER    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","REMOVE_PLAYER"),
    OP_JOIN_AGREED    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","OP_JOIN_AGREED"),
    OP_JOIN_REJECTED    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","OP_JOIN_REJECTED"),
    OP_EXIT_AGREED    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","OP_EXIT_AGREED"),
    OP_EXIT_REJECTED    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","OP_EXIT_REJECTED"),
    OP_APPLY_EXIT    = pb.enum("C2S_CLUB_OP_REQ.C2S_CLUB_OP_TYPE","OP_APPLY_EXIT"),
}

function on_cs_club_create(msg,guid)
    local club_info = msg.info
    if club_info.type == 1 or club_info.parent and club_info.parent ~= 0 then
        local p_club = base_clubs[msg.parent]
        if not p_club then
            log.error("on_cs_club_create no parent club,%s.",msg.parent)
            onlineguid.send(guid,"S2C_CREATE_CLUB_RES",{
                result = enum.ERROR_CLUB_NOT_FOUND,
            })
            return
        end
    end

    local player = base_players[guid]
    if not player then
        log.error("internal error,recv msg but no player.")
        onlineguid.send(guid,"S2C_CREATE_CLUB_RES",{
            result = enum.ERROR_PLAYER_NOT_EXIST,
        })

        return
    end

    dump(player)

    -- if not player:has_club_rights() then
	-- 	return {
    --         result = CLUB_OP_RESULT_NO_RIGHTS,
    --     }
    -- end

    local id = math.random(1000000,9999999)
    for _ = 1,1000 do
        if not base_clubs[id] then break end
        id = math.random(1000000,9999999)
    end

    base_club:create(id,club_info.name,club_info.icon,player,club_info.type,club_info.parent)
	if not id then
		return {
            result = enum.CLUB_OP_RESULT_FAILED,
        }
    end

    base_clubs[id] = nil
    local _ = base_clubs[id]

    onlineguid.send(guid,"S2C_CREATE_CLUB_RES",{
        result = enum.CLUB_OP_RESULT_SUCCESS,
        id = id,
    })
end

function on_cs_club_create_club_with_req(msg,guid)
    local req_info = base_request[msg.req_id]
    if not req_info then
        log.error("on_cs_club_create_club_with_req no parent club,%s.",msg.parent)
        onlineguid.send(guid,"S2C_CREATE_CLUB_RES",{
            result = enum.ERROR_CLUB_OP_EXPIRE,
        })
        return
    end

    local inviter_club_id = req_info.club_id
    local inviter_club = base_clubs[inviter_club_id]
    if not inviter_club then
        log.error("on_cs_club_create_club_with_req no parent club,%s.",msg.parent)
        onlineguid.send(guid,"S2C_CREATE_CLUB_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
        })
        return
    end

    local player = base_players[guid]
    if not player then
        log.error("internal error,recv msg but no player.")
        onlineguid.send(guid,"S2C_CREATE_CLUB_RES",{
            result = enum.ERROR_PLAYER_NOT_EXIST,
        })

        return
    end

    local role = club_role[inviter_club_id][guid]
    if role == enum.CRT_BOSS then
        return
    end

    dump(player)

    -- if not player:has_club_rights() then
	-- 	return {
    --         result = CLUB_OP_RESULT_NO_RIGHTS,
    --     }
    -- end

    local id = math.random(1000000,9999999)
    for _ = 1,1000 do
        if not base_clubs[id] then break end
        id = math.random(1000000,9999999)
    end

    local club_info = msg.club_info

    base_club:create(id,club_info.name,club_info.icon,player,1,inviter_club.id)
	if not id then
		return {
            result = enum.CLUB_OP_RESULT_FAILED,
        }
    end

    base_clubs[id] = nil
    local _ = base_clubs[id]

    onlineguid.send(guid,"S2C_CREATE_CLUB_RES",{
        result = enum.CLUB_OP_RESULT_SUCCESS,
        id = id,
    })
end

function on_cs_club_invite_join_club(msg,guid)
    local club_id = msg.inviter_club
    local club = base_clubs[club_id]
    if not club then
        log.warning("unknown club:%s",club_id)
        onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
        })
        return
    end

    if club_memeber[club_id][guid] then
        log.warning("club member:%s join self club:%s",guid,club_id)
        onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
            result = enum.ERROR_CLUB_OP_JOIN_CHECKED,
        })
        return
    end

    local player_reqs = player_request:all(club.owner)
    for _,req in pairs(player_reqs) do
        if req.who == guid and req.type == "join" then
            onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
                result = enum.ERROR_CLUB_OP_JOIN_REPEATED,
            })
            return
        end
    end

    club:request_join(guid)
    onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
        result = enum.ERROR_NONE,
    })

    player_request[club.owner] = nil
end

function on_cs_club_dismiss(msg,guid)
    local club_id = msg.club_id
    local player = base_players[guid]
    if not player then
        log.error("internal error,recv msg but guid not online.")
        return {
            club_id = club_id,
            result = enum.CLUB_OP_RESULT_INTERNAL_ERROR,
        }
    end

    if not player:has_club_rights() then
        return {
            club_id = club_id,
            result = enum.CLUB_OP_RESULT_NO_RIGHTS,
        }
    end

    local club = base_clubs[club_id]
    if not club then
        return {
            club_id = club_id,
            result = enum.CLUB_OP_RESULT_NO_CLUB,
        }
    end

    club:dismiss()
    for mem,_ in pairs(club_memeber[club_id]) do
        player_club[mem][club_id] = nil
    end
    club_memeber[club_id] = nil
    base_clubs[club_id] = nil

    return {
        club_id = club_id,
        result = enum.CLUB_OP_RESULT_SUCCESS,
    }
end

function on_cs_club_query(msg,guid)
    local club = base_clubs[msg.club_id]
    return {
        id = club.id,
        name = club.name,
        icon = club.icon,
    }
end

function on_cs_club_detail_info_req(msg,guid)
    local club_id = msg.club_id
    if not club_id then
        onlineguid.send(guid,"S2C_CLUB_INFO_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
        })

        return
    end

    local club = base_clubs[club_id]
    if not club then
        onlineguid.send(guid,"S2C_CLUB_INFO_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
        })
        return
    end

    local games = {}
    local info = channel.query()
    for sid,_ in pairs(info) do
        local id = sid:match("service%.(%d+)")
        if id then
            local conf = serviceconf[tonumber(id)]
            if conf.name == "game" then
                local sconf = conf.conf
                games[sconf.first_game_type] = sconf
            end
        end
    end

    local real_games = {}
    local club_games = club_game_type[club_id]
    if table.nums(club_games) ~= 0 then
        for _,game in pairs(club_games or {}) do
            if games[game] then
                table.insert(real_games,game)
            end
        end
    else
        real_games = table.keys(games)
    end

    local tables = {}
    for pid,_ in pairs(club_table[club_id]) do
        local priv_tb = base_private_table[pid]
        local tableinfo = channel.call("game."..priv_tb.room_id,"msg","GetTableStatusInfo",priv_tb.real_table_id)
        table.insert(tables,tableinfo)
    end

    local online_count = 0
    local total_count = 0

    for mem,_ in pairs(club_memeber[club_id]) do
        local p = base_players[mem]
        if p  then
            total_count = total_count + 1
            if p.online then
                online_count = online_count + 1
            end
        end
    end

    local templates = {}
    for ttid,_ in pairs(club_table_template[club_id]) do
        table.insert(templates,table_template[ttid])
    end

    local club_info = {
        result = enum.ERROR_NONE,
        club_info = {
            id = club_id,
            name = club.name,
        },
        my_club_info = {
            role = club_role[club_id][guid] or enum.CRT_PLAYER,
        },
        closed = false,
        player_count = total_count,
        player_num_online = online_count,
        club_diamond = base_players[club.owner].diamond,
        table_list = tables,
        gamelist = real_games,
        table_templates = templates,
    }

    onlineguid.send(guid,"S2C_CLUB_INFO_RES",club_info)
end

function on_cs_club_list(msg,guid)
    log.info("on_cs_club_list,guid:%s",guid)
    local clubs = {}
    for _,club in pairs(base_clubs:list()) do
        if club_memeber[club.id][guid] then
            table.insert(clubs,{
                id = club.id,
                name = club.name,
                icon = club.icon,
                type = club.type
            })
        end
    end

    onlineguid.send(guid,"S2C_CLUBLIST_RES",{
        result = 0,
        clubs = clubs,
    })
end

function on_cs_club_edit_game_type(msg,guid)
    local club_id = msg.club_id
    local club = base_clubs[club_id]
    if not club then
        onlineguid.send(guid,"S2C_EDIT_CLUB_GAME_TYPE_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
        })
        return
    end

    if club.owner ~= guid then
        onlineguid.send(guid,"S2C_EDIT_CLUB_GAME_TYPE_RES",{
            result = enum.ERROR_NOT_IS_CLUB_BOSS,
        })
        return
    end

    
    reddb:sadd("club:game:"..tostring(club_id),table.unpack(msg.game_types))
    club_game_type[club_id] = nil

    onlineguid.send(guid,"S2C_EDIT_CLUB_GAME_TYPE_RES",{
        result = enum.ERROR_NONE,
    })
end

function on_cs_club_join_req(msg,guid)
    local club_id = msg.club_id
    local club = base_clubs[club_id]
    if not club then
        log.warning("unknown club:%s",club_id)
        onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
        })
        return
    end

    if club_memeber[club_id][guid] then
        log.warning("club member:%s join self club:%s",guid,club_id)
        onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
            result = enum.ERROR_CLUB_OP_JOIN_CHECKED,
        })
        return
    end

    local player_reqs = player_request:all(club.owner)
    for _,req in pairs(player_reqs) do
        if req.who == guid and req.type == "join" then
            onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
                result = enum.ERROR_CLUB_OP_JOIN_REPEATED,
            })
            return
        end
    end

    club:request_join(guid)
    onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
        result = enum.ERROR_NONE,
    })

    player_request[club.owner] = nil
end

function on_club_create_table(club,player,chair_count,round,rule)
    local result,global_table_id,tb = club:create_table(player,chair_count,round,rule)
    if result == enum.GAME_SERVER_RESULT_SUCCESS then
        local tableinfo = channel.call("game."..def_game_id,"msg","GetTableStatusInfo",tb.table_id_)
        club:broadcast("S2C_SYNC_TABLES_RES",{
            club_id = club.id,
            room_info = tableinfo,
            sync_table_id = global_table_id,
            sync_type = enum.SYNC_ADD
        })
    end

    return result,global_table_id,tb
end

function on_cs_club_invite_join_req(msg,guid)
    local inviter = guid
    local club_id = msg.inviter_club
    local player = base_players[inviter]
    if not player then
        log.error("internal error,recv msg but guid not online.")
        onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
            result = enum.ERROR_PLAYER_NOT_EXIST,
        })
        return
    end

    if not player:has_club_rights() then
        onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
        })
        return
    end

    local club = base_clubs[club_id]
    if not club then
        onlineguid.send(guid,"S2C_JOIN_CLUB_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
        })
        return
    end

    club:invite_join(msg.guid,guid)
    player_request[msg.guid] = nil
end

function on_cs_club_query_memeber(msg,guid)
    local ms = {}
    for mem,_ in pairs(club_memeber[msg.club_id]) do
        local p = base_players[mem]
        if p then
            table.insert(ms,{
                info = {
                    guid = p.guid,
                    icon = p.open_id_icon,
                    nickname = p.nickname,
                },
                role = club_role[msg.club_id][guid] or enum.CRT_PLAYER
            })
        end
    end

    onlineguid.send(guid,"S2C_CLUB_PLAYER_LIST_RES",{
        player_list = ms,
    })
end

function on_cs_club_publish_notice(msg,guid)

end


function on_cs_club_exit_req(msg,guid)

end

function on_cs_club_request_list_req(msg,guid)
    local club_id = msg.club_id
    local reqs = {}
    for rid,_ in pairs(player_request[guid]) do
        local req = base_request[rid]
        local player = base_players[req.who]
        table.insert(reqs,{
            req_id = req.id,
            type = req.type,
            who = {
                guid = player.guid,
                nickname = player.nickname,
                icon = player.open_id_icon,
            },
        })
    end

    onlineguid.send(guid,"S2C_CLUB_REQUEST_LIST_RES",{
        result = enum.ERROR_NONE,
        club_id = club_id,
        reqs = reqs,
    })
end

local function on_cs_club_blacklist(msg,guid)
    if msg.op == club_op.ADD_TO_BALACK then
        
    elseif msg.op == club_op.REMOVE_TO_BLACK then

    end
end

local function on_cs_club_administrator(msg,guid)
    if msg.op == club_op.ADD_ADMIN then
        
    elseif msg.op == club_op.REMOVE_ADMIN then

    end
end

local function on_cs_club_player(msg,guid)
    local player = base_players[guid]
    if not player then
        log.error("unknown player when kickout player out club:%s",msg.club_id)
        return
    end
    
    if msg.op == club_op.REMOVE_PLAYER then
        base_clubs[msg.club_id].kickout(msg.guid)
    end
end

local function on_cs_club_exit(msg,guid)
    local who = base_players[guid]
	if not who:has_club_rights() then
		return enum.CLUB_OP_RESULT_NO_RIGHTS
	end

    local club_id = msg.club_id
    if base_players[msg.guid] then
        base_clubs[club_id].exit(msg.guid)
        club_memeber[club_id][msg.guid] = nil
        player_club[msg.guid][club_id] = nil
    end
    
    return enum.CLUB_OP_RESULT_SUCCESS
end

local function on_cs_club_agree_request(msg,guid)
    local player = base_players[guid]
    if not player then
        log.error("unknown player when agree request id:%s",msg.request_id)
        
        onlineguid.send(guid,"S2C_CLUB_OP_RES",{
            result = enum.ERROR_PLAYER_NOT_EXIST,
            op_type = msg.op,
        })
        return
    end

    local request = base_request[msg.request_id]
    if not request then
        log.error("unknown player when agree request id:%s",msg.request_id)
        onlineguid.send(guid,"S2C_CLUB_OP_RES",{
            result = enum.ERROR_CLUB_OP_EXPIRE,
            op_type = msg.op,
        })
        return
    end

    if not request:agree() then
        log.error("agree request failed,id:%s",msg.request_id)
        onlineguid.send(guid,"S2C_CLUB_OP_RES",{
            result = enum.ERROR_CLUB_OP_EXPIRE,
            op_type = msg.op,
        })

        return
    end

    -- 更新数据
    player_request[request.whoee] = nil
    base_request[request.id] = nil
    club_memeber[request.club_id] = nil

    onlineguid.send(guid,"S2C_CLUB_OP_RES",{
        result = enum.ERROR_NONE,
        op_type = msg.op,
    })
end

local function on_cs_club_reject_request(msg,guid)
    dump(msg)
    local player = base_players[guid]
    if not player then
        log.error("unknown player when reject request request_id:%s",msg.request_id)
        onlineguid.send(guid,"S2C_CLUB_OP_RES",{
            result = enum.ERROR_PLAYER_NOT_EXIST,
            op = msg.op,
        })
        return
    end

    local request = base_request[tonumber(msg.request_id)]
    if not request then
        log.error("unknown request when reject request request_id:%s",msg.request_id)
        onlineguid.send(guid,"S2C_CLUB_OP_RES",{
            result = enum.ERROR_CLUB_OP_EXPIRE,
            op = msg.op,
        })
        return
    end

    local club = base_clubs[request.club_id]
    if not club then
        log.error("unkonw club_id when reject request,id:%s",msg.request_id)
        onlineguid.send(guid,"S2C_CLUB_OP_RES",{
            result = enum.ERROR_CLUB_NOT_FOUND,
            request_id = msg.request_id,
        })
        return
    end

    if not club:reject_request(request) then
        log.error("reject request failed,id:%s",msg.request_id)
        onlineguid.send(guid,"S2C_CLUB_OP_RES",{
            result = enum.ERROR_CLUB_OP_EXPIRE,
            request_id = msg.request_id,
        })

        return
    end

    player_request[request.who][request.id] = nil
    base_request[request.id] = nil
    club_memeber[request.club_id] = nil

    onlineguid.send(guid,"S2C_CLUB_OP_RES",{
        result = enum.ERROR_NONE,
        request_id = msg.request_id,
    })
end

local operator = {
    [club_op.ADD_TO_BLACK] = on_cs_club_blacklist,
    [club_op.REMOVE_TO_BLACK] = on_cs_club_blacklist,
    [club_op.ADD_ADMIN] = on_cs_club_administrator,
    [club_op.REMOVE_ADMIN] = on_cs_club_administrator,
    [club_op.REMOVE_PLAYER] = on_cs_club_player,
    [club_op.OP_JOIN_AGREED] = on_cs_club_agree_request,
    [club_op.OP_JOIN_REJECTED] = on_cs_club_reject_request,
    [club_op.OP_EXIT_AGREED] = on_cs_club_agree_request,
    [club_op.OP_EXIT_REJECTED] = on_cs_club_reject_request,
    [club_op.OP_APPLY_EXIT] = on_cs_club_exit,
}

function on_cs_club_operation(msg,guid)
    local f = operator[msg.op]
    if f then
        f(msg,guid)
    end
end

function on_cs_club_invite_create_req(msg,guid)

end

function on_cs_club_kickout(msg,guid)

end

function on_cs_club_dismiss_table(msg,guid)

end

function on_cs_club_lock_table(msg,guid)

end

function on_cs_club_unlock_table(msg,guid)
    
end

function on_cs_online_member_without_gaming(msg,guid)

end

function on_cs_invite_member_to_game(msg,guid)

end

function on_cs_response_invite_to_game(msg,guid)

end
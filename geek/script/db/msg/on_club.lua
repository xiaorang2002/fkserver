
local dbopt =  require "dbopt"
local log = require "log"
local enum = require "pb_enums"

function on_sd_create_club(msg)
    dump(msg)
    local club_info = msg.info
    local money_info = msg.money_info
    if not club_info.owner or not club_info.id then
        log.error("on_sd_create_club invalid id or owner,id:%s,owner:%s",club_info.id,club_info.owner)
        return
    end

    local gamedb = dbopt.game
     
    if club_info.parent and club_info.parent ~= 0 then
        local res = gamedb:query("SELECT * FROM t_club WHERE id = %d;",club_info.parent)
        if res.errno then
            log.error("on_sd_create_club query parent error:%d,%s",res.errno,res.err)
            return
        end
    end

    local transqls = {
        "SET AUTOCOMMIT = 0;",
        "BEGIN;",
        string.format([[INSERT INTO t_club(id,name,owner,icon,type,parent) SELECT %d,'%s',%d,'%s',%d,%d 
                        WHERE EXISTS (SELECT * FROM t_player WHERE guid = %d);]],
                    club_info.id,club_info.name,club_info.owner,club_info.icon,club_info.type,club_info.parent,club_info.owner),
        string.format([[INSERT INTO t_club_money(club,money_id,money) VALUES(%d,%d,0),(%d,0,0);]],club_info.id,money_info.id,club_info.id),
        string.format([[INSERT INTO t_club_member(club,guid) VALUES(%d,%d);]],club_info.id,club_info.owner),
        string.format([[INSERT INTO t_player_money(guid,money_id,money) SELECT %d,%d,0
            WHERE NOT EXISTS (SELECT * FROM t_player_money WHERE guid = %d AND money_id = %d);]],
            club_info.owner,money_info.id,club_info.owner,money_info.id),
        string.format([[INSERT INTO t_club_money_type(money_id,club) VALUES(%d,%d);]],money_info.id,club_info.id),
        "COMMIT;",
    }

    dump(transqls)

    local trans = gamedb:transaction()
    local res = trans:execute(table.concat(transqls,"\n"))
    if res.errno then
        log.error("on_sd_create_club transaction sql error:%d,%s",res.errno,res.err)
        trans:execute("ROLLBACK;")
        return
    end

    return true
end

function on_sd_join_club(msg)
    dump(msg)
    local gamedb = dbopt.game
    local res = gamedb:query("SELECT COUNT(*) AS c FROM t_player WHERE guid = %d;",msg.guid)
    if res.errno then
        log.error("on_sd_join_club query player error:%d,%s",res.errno,res.err)
        return
    end

    if res[1].c ~= 1 then
        log.error("on_sd_join_club check player got wrong player count,guid:%s",msg.guid)
        return
    end

    res = gamedb:query("SELECT COUNT(*) AS c FROM t_club WHERE id = %d;",msg.club_id)
    if res.errno then
        log.error("on_sd_join_club query player error:%d,%s",res.errno,res.err)
        return
    end

    if res[1].c ~= 1 then
        log.error("on_sd_join_club check club got wrong player count,club:%s",msg.club_id)
        return
    end

    local sqls = {
        "SET AUTOCOMMIT = 0;",
        "BEGIN;",
        string.format([[INSERT INTO t_club_member(club,guid) SELECT %d,%d
            WHERE NOT EXISTS (SELECT * FROM t_club_member WHERE club = %d AND guid = %d);]],
            msg.club_id,msg.guid,msg.club_id,msg.guid,msg.guid),
        string.format([[INSERT INTO t_player_money
            (SELECT %d,money_id,0,0 FROM (SELECT * FROM t_club_money_type WHERE club = %d) m
            WHERE NOT EXISTS (SELECT * FROM t_player_money WHERE guid = %d AND money_id = m.money_id));]],
            msg.guid,msg.club_id,msg.guid),
        "COMMIT;"
    }

    dump(sqls)

    local tran = dbopt.game:transaction()
    res = tran:execute(table.concat(sqls,"\n"))
    if res.errno then
        tran:execute("ROLLBACK;")
        log.error("on_sd_join_club error:%d,%s",res.errno,res.err)
        return
    end

    dump(res)

    return true
end

function on_sd_exit_club(msg)
    local res = dbopt.game:query("DELETE FROM t_club_member WHERE guid = %d AND club = %d;",msg.guid,msg.club_id)
    if res.errno then
        log.error("on_sd_exit_club DELETE member error:%d,%s",res.errno,res.err)
        return
    end

    return true
end

function on_sd_dismiss_club(msg)

end

function on_sd_add_club_member(msg)
    local club_id = msg.club_id
    local guid = msg.guid

    dump(msg)

    dbopt.game:query("INSERT INTO t_club_member(club,guid) VALUES(%d,%d);",club_id,guid)
end

local function incr_club_money(club,money_id,money,why,why_ext)
    local sqls = {
        "SET AUTOCOMMIT = 0;",
        "BEGIN;",
        string.format("SELECT money FROM t_club_money WHERE club = %d AND money_id = %d;",club,money_id),
        string.format("UPDATE t_club_money SET money = money + (%d) WHERE club = %d AND money_id = %d;",money,club,money_id),
        string.format("SELECT money FROM t_club_money WHERE club = %d AND money_id = %d;",club,money_id),
        "COMMIT;",
    }

    dump(sqls)

    local tran = dbopt.game:transaction()
    local res = tran:execute(table.concat(sqls,"\n"))
    if res.errno then
        tran:execute("ROLLBACK;")
        log.error("incr_club_money insert UPDATE money error,errno:%d,err:%s",res.errno,res.err)
        return
    end

    local oldmoney = res[3] and res[3][1] and res[3][1].money or nil
    local newmoney = res[5] and res[5][1] and res[5][1].money or nil

    if oldmoney and newmoney then
        res = dbopt.log:execute("INSERT INTO t_log_money_club SET $FIELD$;", {
            club = club,
            money_id = money_id,
            old_money = oldmoney,
            new_money = newmoney,
            opt_type = why,
            opt_ext = why_ext,
        })
        if res.errno then
            log.error("incr_club_money insert log.t_log_money_club error,errno:%d,err:%s",res.errno,res.err)
            return
        end
    end

	return oldmoney,newmoney
end

function on_sd_change_club_money(items,why,why_ext)
    dump(items)
	local changes = {}
	for _,item in pairs(items) do
		local oldmoney,newmoney = incr_club_money(item.club,item.money_id,item.money,why,why_ext)
		table.insert(changes,{
			oldmoney = oldmoney,
			newmoney = newmoney,
		})
    end

	return changes
end

function on_sd_create_club_template(msg)
    dump(msg)
    local res = dbopt.game:query([[
        INSERT INTO t_template(id,club,rule,description,game_id,created_time,status)
        VALUES(%d,%d,'%s','%s',%d,%d,0);
        ]],msg.id,msg.club_id,msg.rule,msg.description,msg.game_id,os.time())
    if res.errno then
        log.error("on_sd_create_club_template INSERT template errno:%d,errstr:%s",res.errno,res.err)
    end
end

function on_sd_remove_club_template(msg)
    dump(msg)
    local res = dbopt.game:query([[UPDATE t_template SET status = 1 WHERE id = %d;]],msg.id)
    if res.errno then
        log.error("on_sd_remove_club_template UPDATE template errno:%d,errstr:%s",res.errno,res.err)
    end
end

function on_sd_edit_club_template(msg)
    local res = dbopt.game:query([[
        UPDATE t_template SET club = %d,rule = '%s',description = '%s',game_id = %d
        WHERE id = %d;
        ]],msg.club_id,msg.rule,msg.description,msg.game_id,msg.id)
    if res.errno then
        log.error("on_sd_edit_club_template UPDATE template errno:%d,errstr:%s",res.errno,res.err)
    end
end
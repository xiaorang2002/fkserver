local skynet = require "skynetproto"
local log = require "log"
local channel = require "channel"
local base_players  = require "game.lobby.base_players"
local base_room = require "game.lobby.base_room"
local base_private_table = require "game.lobby.base_private_table"
local timer = require "timer"
require "functions"
local msgopt = require "msgopt"
local enum = require "pb_enums"
local redisopt = require "redisopt"
local reddb = redisopt.default

LOG_NAME = "game"

local private_table_elapsed_seconds = 60 * 60 * 2

register_dispatcher = msgopt.register

def_game_name = nil
def_game_id = nil
global_conf = nil
def_first_game_type = nil
def_second_game_type = nil
open_lan_mate = true
g_room = nil
g_prize_pool = nil

--维护开关响应(全局变量0正常,1进入维护中,默认正常)
cash_switch = 0  --提现开关全局变量
game_switch = 0  --游戏开关全局变量


local function checkgameconf(conf)
	assert(conf)
	assert(conf.id)
	assert(conf.name)
	assert(conf.type)
	assert(conf.conf)
	local game_conf = conf.conf
	assert(game_conf.gamename)
	assert(game_conf.first_game_type)
	assert(game_conf.second_game_type)
	assert(game_conf.player_limit)
	assert(game_conf.table_count)
	assert(game_conf.money_limit)
	assert(game_conf.cell_money)
	assert(game_conf.tax_open)
	assert(game_conf.tax_show)
	assert(game_conf.tax)
	assert(game_conf.room_cfg)
	assert(game_conf.switch_is_open)
	assert(game_conf.platform_id)
end

function get_register_money()
    return global_conf.register_money
end

function get_private_room_bank()
    return global_conf.private_room_bank
end

local function clean_private_table()
	log.info("try to clean up private table ...")
	local table_keys = reddb:keys("table:info:*")
	for _,table_key in pairs(table_keys) do
		local tid = string.match(table_key,"table:info:(%d+)")
		tid = tonumber(tid)
		local info = base_private_table[tid]
		if info.game_type == def_first_game_type and (os.time() - info.create_time) >= private_table_elapsed_seconds then
			log.warning("dismiss elapsed table: %s ...",tid)
			log.dump(info)
			g_room:force_dismiss_table(info.real_table_id)
		end
	end
	timer.timeout(60 * 5,clean_private_table)
end


local CMD = {}

function CMD.start(conf)
	checkgameconf(conf)
	local sconf = conf
	local gameconf = sconf.conf
	def_game_name = gameconf.gamename
	def_game_id = sconf.id
	def_first_game_type = gameconf.first_game_type
	def_second_game_type = gameconf.second_game_type
	global_conf = channel.call("config.?","msg","global_conf")

	LOG_NAME = def_game_name .. "." .. def_first_game_type

	log.info("start game %s.%d.%d",gameconf.gamename,gameconf.first_game_type,gameconf.second_game_type)

	local boot = require("game."..def_game_name..".bootstrap")
	g_room = boot(gameconf)

	require "game.lobby.register"
	require "game.club.register"
	require "game.mail.register"
	require "game.reddot.register"
	require "game.notice.register"
	require "hotfix"
	require "game.lobby.base_android"
	require "game.lobby.gm_cmd"
	local timer_manager = require "game.timer_manager"
	
	local base_passive_android = base_passive_android
	local room = g_room
		
	local function on_tick()
		timer_manager:tick()
		base_players:save_all()
		base_passive_android:on_tick()
		room:tick()

		skynet.timeout(4,on_tick)
	end
	
	on_tick()

	timer.timeout(60 * 5,clean_private_table)
end

function CMD.afk(guid,offline)
	if not guid then
		return
	end

	local player = base_players[guid]
	if not player then
		return
	end

	log.info("on gate afk,guid:%s,offline:%s",guid,offline)

	return logout(player.guid,offline)
end

function CMD.get_player_count()
	return g_room.cur_player_count_
end

skynet.start(function()
	skynet.dispatch("lua",function(_,_,cmd,...) 
        local f = CMD[cmd]
        if not f then
			log.error("unknow cmd:%s",cmd)
			skynet.retpack(nil)
            return
        end

        skynet.retpack(f(...))
	end)

	skynet.dispatch("msg",function(_,_,cmd,...)
        skynet.retpack(msgopt.on_msg(cmd,...))
	end)
	
    collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end)
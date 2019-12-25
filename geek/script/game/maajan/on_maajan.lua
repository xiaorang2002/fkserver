-- 诈金花消息处理

local pb = require "pb_files"

require "game.net_func"
local send2client_pb = send2client_pb

local base_players = require "game.lobby.base_players"

function on_cs_act_win(player, msg)
	print ("test .................. on_cs_act_win")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_win(player, msg)
	end
end
function on_cs_act_double(player, msg)
	print ("test .................. on_cs_act_double")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_double(player, msg)
	end
end

function on_cs_act_discard(player, msg)
	print ("test .................. on_cs_act_discard")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_discard(player, msg)
	end
end
function on_cs_act_peng(player, msg)
	print ("test .................. on_cs_act_peng")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_peng(player, msg)
	end
end
function on_cs_act_gang(player, msg)
	print ("test .................. on_cs_act_gang")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_gang(player, msg)
	end
end
function on_cs_act_pass(player, msg)
	print ("test .................. on_cs_act_pass")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_pass(player, msg)
	end
end
function on_cs_act_chi(player, msg)
	print ("test .................. on_cs_act_chi")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_chi(player, msg)
	end
end
function on_cs_act_trustee(player, msg)
	print ("test .................. on_cs_act_trustee")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_trustee(player, msg)
	end
end
function on_cs_act_baoting(player, msg)
	print ("test .................. on_cs_act_baoting")
	local tb = g_room:find_table_by_player(player)
	if tb then
		tb:on_cs_act_baoting(player, msg)
	end
end


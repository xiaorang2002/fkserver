-- 跑得快消息处理

local log = require "log"
local base_players = require "game.lobby.base_players"
local room = require "game.pdk.pdk_room"

-- 出牌
function on_cs_pdk_do_action(msg,guid)
	local player = base_players[guid]
	if not player then
		log.error("on_cs_pdk_do_action player not found.")
		return
	end

	local tb = room:find_table_by_player(player)
	if tb then
		tb:do_action(player, msg)
	else
		log.error(string.format("on_cs_pdk_do_action guid[%d] not in table.", guid))
	end
end

function  on_cs_pdk_trustee(msg, guid)
	local player = base_players[guid]
	if not player then
		log.error("on_cs_pdk_trustee player not found.")
		return
	end

	local tb = room:find_table_by_player(player)
	if tb then
		tb:set_trusteeship(player,false)
	else
		log.error(string.format("guid[%d] LandTrusteeship", player.guid))
	end
end
local pb = require "pb_files"
local tablex = require "tablex"

local base_table = require "game.lobby.base_table"
require "game.banker_ox.banker_gamelogic"
require "data.texas_data"
require "table_func"
local log = require "log"
local random = require "random"

require "game.banker_ox.banker_robot_1"
local banker_android = banker_android

local ITEM_PRICE_TYPE_GOLD = pb.enum("ITEM_PRICE_TYPE", "ITEM_PRICE_TYPE_GOLD")
local GAME_SERVER_RESULT_SUCCESS = pb.enum("GAME_SERVER_RESULT", "GAME_SERVER_RESULT_SUCCESS")

local banker_table = base_table:new()

local DEBUG_MODE = true

local	BANKER_CARD_TYPE_NONE           = 100;
local	BANKER_CARD_TYPE_ONE            = 101;
local	BANKER_CARD_TYPE_TWO            = 102;
local   BANKER_CARD_TYPE_THREE 			= 103;
local	BANKER_CARD_TYPE_FOUR 			= 104;
local	BANKER_CARD_TYPE_FIVE 			= 105;
local	BANKER_CARD_TYPE_SIX 			= 106;
local	BANKER_CARD_TYPE_SEVEN 			= 107;
local	BANKER_CARD_TYPE_EIGHT 			= 108;
local	BANKER_CARD_TYPE_NIGHT 			= 109;
local	BANKER_CARD_TYPE_TEN			= 110;
local	BANKER_CARD_TYPE_FOUR_KING		= 201;
local	BANKER_CARD_TYPE_FIVE_KING		= 202;
local	BANKER_CARD_TYPE_FOUR_SAMES		= 203;
local	BANKER_CARD_TYPE_FIVE_SAMLL		= 204;

local SYS_CARDS_NUM = 52
local SYS_CARDS_VALUE = 37

local ACTION_INTERVAL_TIME  = 2
local STAGE_INTERVAL_TIME   = 2

local STATUS_WAITING		= 0
local STATUS_SEND_CARDS		= 1
local STATUS_CONTEND_BANKER	= 2
local STATUS_CONTEND_END 	= 3
local STATUS_DICISION_BANKER= 4
local STATUS_BET			= 5
local STATUS_BET_END		= 6
local STATUS_SHOW_CARD		= 7
local STATUS_SHOW_CARD_END  = 8

local STATUS_SHOW_DOWN		= 9
local STATUS_OVER			= 10

local LOG_MONEY_OPT_TYPE_BANKER_OX = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BANKER_OX")


local PLAYER_STATUS_READY	= 1
local PLAYER_STATUS_GAME	= 1
local PLAYER_STATUS_OFFLINE	= 3

local POSITION_BANKER		= 1
local POSITION_NORMAL		= 2

local CS_ERR_OK = 0 	 --正常
local CS_ERR_MONEY = 1   --钱不够
local CS_ERR_STATUS = 2  --状态和阶段不同步错误

local START_TIME = 5
local CONTEND_BANKER_TIME = 6
local DICISION_BANKER = 5
local BET_TIME = 6
local SHOWCARD_TIME = 5
local END_TIME = 5


-- 下注倍数选项
local bet_times_option = {5,10,15,20}
-- 最大索引
local MAX_CARDS_INDEX = 1
-- 最小索引
local MIN_CARDS_INDEX = 2

--中奖公告标准,超过该标准全服公告
local BANKER_OX_GRAND_PRICE_BASE = 20000

local getNum = getNum

--将有牛的牌型换到前面4玩家可见的概率
local EXCHANGE_COEFF = 60

function banker_table:init_load_texas_config_file()
 	package.loaded["data/texas_data"] = nil
	require "data.texas_data"
end

function banker_table:load_texas_config_file()
	TEXAS_FreeTime = texas_room_config.Texas_FreeTime
	--print("BetTime = "..OX_TIME_ADD_SCORE)
end

--重置
function banker_table:reset()
	self.b_status = STATUS_WAITING
	self.b_timer = 0
	--self.b_status_table = TABLE_STAT_BETTING
	--self.b_pob_player = {}	-- to load from config

	self.rand_key = 3
	self.b_ret = {}
	self.b_pool = 0
	self.b_player = {}
	self.b_end_player = {}
	self.b_player_count = 0
	self.b_banker = {guid = 0}
	self.b_recoonect = {}
	--self.b_max_bet = 0

	self.b_total_time = 0
	self.b_contend_count = {}
	self.b_bet_count = {}
	self.b_guess_count = {}
	self.b_table_busy = 0
	self.player_contend_count = {} --统计抢庄发话人数

	self.t_card_set = {}
	local cards_num = SYS_CARDS_NUM
	for i = 1, cards_num do
		self.t_card_set[i] = i - 1
	end
end

-- 初始化 0 - 51
function banker_table:init(room, table_id, chair_count)
	base_table.init(self, room, table_id, chair_count)
	self.b_player = {}
	self:reset()
	--self:init_load_texas_config_file()
	--self:load_texas_config_file()
	self.b_tax = self.room_:get_room_tax()
	self.b_bottom_bet = self.room_:get_room_cell_money()

	self.area_cards_ = {} --区域里的牌
	--self:test_card()
	-- 计分板
	self.last_score_record = {}
	self.banker_player_record = {}

	self.black_rate = 0

	--初始化不同变量和基础配置
	if def_first_game_type == 14 then
		if def_second_game_type == 4 then --银牛场
			bet_times_option = {10,15,20,30}
		elseif def_second_game_type == 5 or def_second_game_type == 6 then --金牛或神牛场
			bet_times_option = {10,20,30,40}
		end
		log.info("banker_ox:-------->type[%d]:bet_times_option:[%d,%d,%d,%d]",def_second_game_type,bet_times_option[1],bet_times_option[2],bet_times_option[3],bet_times_option[4])
	end
	self:robot_init()
end

local SYSTEM_BEAST_PROB = 3
local SYSTEM_FLOAT_PROB = 2
function banker_table:load_lua_cfg()
	print ("--------------------###############################load_lua_cfg", self.room_.room_cfg)
	log.info("banker_table: game_maintain_is_open = [%s]",self.room_.game_switch_is_open)
	local fucT = load(self.room_.room_cfg)
	local banker_config = fucT()

	if banker_config then
		if banker_config.SYSTEM_BEAST_PROB then
			SYSTEM_BEAST_PROB = banker_config.SYSTEM_BEAST_PROB
			log.info("#########SYSTEM_BEAST_PROB:[%f]",SYSTEM_BEAST_PROB)
		end

		if banker_config.SYSTEM_FLOAT_PROB then
			SYSTEM_FLOAT_PROB = banker_config.SYSTEM_FLOAT_PROB
			log.info("#########SYSTEM_FLOAT_PROB:[%f]",SYSTEM_FLOAT_PROB)
		end

		if banker_config.BANKER_OX_GRAND_PRICE_BASE then
			BANKER_OX_GRAND_PRICE_BASE = banker_config.BANKER_OX_GRAND_PRICE_BASE
			log.info("#########BANKER_OX_GRAND_PRICE_BASE:[%d]",BANKER_OX_GRAND_PRICE_BASE)
		end

		if banker_config.BASIC_BET_TIMES then
			bet_times_option = banker_config.BASIC_BET_TIMES
			log.info("######### banker_ox:bet_times_option:[%d,%d,%d,%d]",bet_times_option[1],bet_times_option[2],bet_times_option[3],bet_times_option[4])
		end

		if banker_config.black_rate then
			self.black_rate = banker_config.black_rate
			log.info("#########self.black_rate:[%d]",self.black_rate)
		end

		if banker_config.robot_switch then
			self.robot_switch = banker_config.robot_switch
			log.info("#########self.robot_switch:[%d]",self.robot_switch)
		end

		self:init_robot_random()
		if banker_config.robot_strategy then
			self.robot_strategy = banker_config.robot_strategy
			log.info("#########self.robot_strategy:error")
		end


		if banker_config.robot_bet then
			self.robot_bet = banker_config.robot_bet
			log.info("#########self.robot_strategy:error")
		end

		if banker_config.robot_change_card then
			self.robot_change_card = banker_config.robot_change_card
			log.info("#########self.robot_change_card: [%d]", self.robot_change_card)
		end
		self:run_rob_ramdom_value()
	else
		print("land_config is nil")
	end
end
-- 心跳
function banker_table:tick()

	self:check_robot_enter()

	if self.b_timer < get_second_time() then

		if self.b_table_busy == 0 and getNum(self.players) > self.b_player_count then

			for i,v in pairs(self.players) do
				if v then
					---print("--------------------C", v , v.guid, v.enterTime , v.enterTime > get_second_time() - 15 , v.enterTime < get_second_time() - 13 )

				end
				if v and v.enterTime and v.enterTime > get_second_time() - 15 and v.enterTime < get_second_time() - 13 then
					log.info("player[%d] time out  forced_exit room[%s]",v.guid , tostring(v.room_id))
					v.enterTime = nil
					v:forced_exit()
				end
			end
		end
		self.b_timer = get_second_time()
	end
	if get_second_time() < self.b_timer then
		return
	end
	if self.b_status == STATUS_OVER then
		for i,player in pairs(self.players) do
			if player and player.banker_enterflag == true then
				if player then
					self:playerReady(player)
				else
					log.info("v is nil:"..i)
				end
			end
		end
		print("self.b_status = STATUS_WAITING")
		self.b_status = STATUS_WAITING
	end
	if self.b_player_count > 1 and self.b_table_busy == 0 and self.b_status ~= STATUS_OVER then
		--self.b_status = STATUS_SEND_CARDS
		log.info("player > 1 time [%s]",tostring(get_second_time()))
		self.b_table_busy = 1
		self.b_timer = get_second_time() + START_TIME
		local msg = {
			s_start_time = self.b_timer - get_second_time() - 1
		}
		self.last_score_record = self.banker_player_record
		self.banker_player_record = {}
		self:t_broadcast("SC_StartCountdown", msg)
		return
	end

	if self.b_table_busy == 1 and self.b_status == STATUS_WAITING and self.b_player_count > 1 then
		-- 开始 游戏
		if base_table.start(self) == nil then
			log.info("cant Start Game ====================================================")
			return
		end

		for i,v in pairs (self.players) do
			if v and v.ready ~= true then
				v:forced_exit()
			end
		end
		self.b_status = STATUS_SEND_CARDS
		log.info("b_status = STATUS_SEND_CARDS   time [%s]",tostring(get_second_time()))
	end

	if self.b_table_busy == 1 and self.b_status > STATUS_WAITING and self.b_status < STATUS_OVER then
		self:game_start()
	end

	if self.b_status == STATUS_OVER then
		self:reset()
	end
end


--game
function banker_table:game_start()
	if self.b_status == STATUS_SEND_CARDS then
		self:send_player_cards()
	elseif self.b_status == STATUS_CONTEND_BANKER then
		self:begin_to_contend()
	elseif self.b_status == STATUS_CONTEND_END then
		self:decide_banker()
	elseif self.b_status == STATUS_BET then
		self:begin_bet()
	 elseif self.b_status == STATUS_BET_END then
	 	self:show_cards()
	 elseif self.b_status == STATUS_SHOW_CARD_END then
	 	self:send_result()
	end
end

function banker_table:can_enter(player)
	log.info("banker_table:can_enter ===============")

	if self.b_table_busy == 1 and self.b_status == STATUS_WAITING and self.b_timer <= get_second_time() + 1 then
		log.warning("Game jast begin can not enter")
		return false
	end


	if player.vip == 100 then
		if self.b_player_count >= 5 then
			log.info("player[%d] can_enter room[%d] table[%d] false",player.guid, self.room_.id,self.table_id_)
			return false
		end
		if self.b_table_busy == 1 then
			player.banker_enterflag = nil
		end
		player.is_offline = false
		return true
	end
	if player then
		log.info ("player have date guid[%d] room[%d] table[%d] ",player.guid, self.room_.id,self.table_id_)
	else
		log.info ("player no data")
		return false
	end

	for _,v in ipairs(self.players) do
		if v and v.guid ~= player.guid then
			if player:judge_ip(v) then
				log.info("land_table:can_enter false ip limit")
				return false
			end
		end
	end

	print("======== banker_table:can_enter =====")
	--if self.b_table_busy == 1 or self.b_player_count == 5 then
	if self.b_player_count >= 5 then
		log.info("player[%d] can_enter room[%d] table[%d] false",player.guid, self.room_.id,self.table_id_)
		return false
	end
	if self.b_table_busy == 1 then
		player.banker_enterflag = nil
	end
	print("------- banker_table:can_enter true    ")

	log.info("player[%d] can_enter room[%d] table[%d] true",player.guid, self.room_.id,self.table_id_)
	--self.b_timer = get_second_time() + 1
	log.info("player[%d] is_offline false",player.guid)
	player.is_offline = false
	return true
end

function banker_table:test_card()
	local good_cards_num = 0
	local have_ox_num = 0
	local player_Num_test = 4
	for i=1,10 do
		have_ox_num = 0
		good_cards_num = 0
		for j=1,10000 do

			local user_cards_idx = 0
			self.t_card_set = {}
			local cards_num = SYS_CARDS_NUM
			for i = 1, cards_num do
				self.t_card_set[i] = i - 1
			end
			local setCount = getNum(self.t_card_set) or SYS_CARDS_NUM
			--log.info("user_cards_idx is  [%d]",user_cards_idx)

			local cards_ = nil
			local prob = random.boost_integer(0,100)
			local Goocards = 3 + random.boost_integer(0,2)
			local isGoodCard = false
			if prob <  Goocards then
				isGoodCard = true
				good_cards_num = good_cards_num + 1
			end

			--  log.info("*********************")
			for k=1,player_Num_test do
				local save_cards = {}
				--log.info("Goocards is [%d] prob is [%d]" , Goocards, prob)
				if prob <  Goocards then
					-- 做牌型
					--log.info("get goold cards")
					cards_ = { true, true , true , false , false }
					local a, b , c , d = random.boost_integer(1,5), random.boost_integer(1,5), random.boost_integer(1,5), random.boost_integer(1,5)

					--log.info("a is [%d] b is [%d] c is [%d] d is [%d]" , a, b ,c ,d)
					if a ~= b then
						cards_[a] ,cards_[b] = cards_[b] ,cards_[a]
					end
					if c ~= d then
						cards_[c] ,cards_[d] = cards_[d] ,cards_[c]
					end
				else
					-- 不做牌型
					cards_ = { false , false , false , false , false }
				end

				local haveTenCards = true
				-- log.info("=============================")
				for i = 1,5 do
					local idx = 0
					if cards_[i] then
						if setCount - user_cards_idx >= SYS_CARDS_VALUE then
							idx = random.boost_integer(SYS_CARDS_VALUE,setCount - user_cards_idx)
							-- log.info("==== %d [%d]",idx,self.t_card_set[idx])
						else
							if haveTenCards then
								local x = 1
								idx = 0
								while( x < setCount - user_cards_idx and idx == 0 ) do
									if self.t_card_set[x] >= 36 then
										idx = x
									end
									x = x + 1
								end
								if idx == 0 then
									haveTenCards = false
								end
							end

							if idx == 0 then
								idx = random.boost(1,setCount - user_cards_idx)
							end
						end
					else
						idx = random.boost(1,setCount - user_cards_idx)
						--log.info("tt i is [%d] idx is [%d]" ,i, idx)
					end
					local card = self.t_card_set[idx]
					table.insert(save_cards, card)
					self.t_card_set[idx] = self.t_card_set[getNum(self.t_card_set) - user_cards_idx]
					self.t_card_set[getNum(self.t_card_set) - user_cards_idx] = card
					user_cards_idx = user_cards_idx + 1
				end
				if isGoodCard then
					local ox_type_,value_list_,color_, extro_num_, sort_cards_ = get_cards_type(save_cards)
					local times = get_type_times(ox_type_,extro_num_)
					if ox_type_ > 100 then
						have_ox_num = have_ox_num + 1
					else
						log.info("cards[%s] type[%d]",table.concat(save_cards,","),ox_type_)
					end
				end
			end

		end
		log.info("have_ox_num = [%d] ,good_cards_num = [%d] [%d]",have_ox_num,good_cards_num * player_Num_test,good_cards_num)
	end
end

function banker_table:get_rand_key( ... )
	-- body
	local  rand_key =  random.boost_integer(0 , 22)
	if rand_key == 0 then
		self.rand_key = 0
	elseif rand_key == 2 then
		self.rand_key = self.room_.cur_player_count_
	elseif rand_key == 3 then
		self.rand_key = self.room_.cur_player_count_ + def_first_game_type
	elseif rand_key == 4 then
		self.rand_key = self.room_.cur_player_count_ + def_first_game_type + def_second_game_type
	elseif rand_key == 5 then
		self.rand_key = self.room_.cur_player_count_ + get_second_time()
	elseif rand_key == 6 then
		self.rand_key = self.room_.cur_player_count_ + def_first_game_type + get_second_time()
	elseif rand_key == 7 then
		self.rand_key = self.room_.cur_player_count_ + def_first_game_type + def_second_game_type + get_second_time()
	elseif rand_key == 8 then
		self.rand_key = def_first_game_type
	elseif rand_key == 9 then
		self.rand_key = def_first_game_type + def_second_game_type
	elseif rand_key == 10 then
		self.rand_key = def_first_game_type + get_second_time()
	elseif rand_key == 11 then
		self.rand_key = def_first_game_type + def_second_game_type + get_second_time()
	elseif rand_key == 12 then
		self.rand_key = self.rand_key + self.room_.cur_player_count_
	elseif rand_key == 13 then
		self.rand_key = self.rand_key + self.room_.cur_player_count_ + def_first_game_type
	elseif rand_key == 14 then
		self.rand_key = self.rand_key + self.room_.cur_player_count_ + def_first_game_type + def_second_game_type
	elseif rand_key == 15 then
		self.rand_key = self.rand_key + self.room_.cur_player_count_ + def_first_game_type + get_second_time()
	elseif rand_key == 16 then
		self.rand_key = self.room_.cur_player_count_ + def_first_game_type + def_second_game_type + get_second_time()
	elseif rand_key == 17 then
		self.rand_key = self.rand_key + def_first_game_type
	elseif rand_key == 18 then
		self.rand_key = self.rand_key + def_first_game_type + def_second_game_type
	elseif rand_key == 19 then
		self.rand_key = self.rand_key + get_second_time()
	elseif rand_key == 20 then
		self.rand_key = self.rand_key + def_first_game_type + get_second_time()
	elseif rand_key == 21 then
		self.rand_key = self.rand_key + def_first_game_type + def_second_game_type + get_second_time()
	else
		self.rand_key = 0
	end
end

function  banker_table:get_cards()
	log.info("==============banker_table:get_cards==================")
	local user_cards_idx = 0
	self:get_rand_key()
	local prob = random.boost_key(0,100,self.rand_key)
	local Goocards = SYSTEM_BEAST_PROB + random.boost_key(0,SYSTEM_FLOAT_PROB,self.rand_key + 1)
	local setCount = getNum(self.t_card_set) or SYS_CARDS_NUM
	local cards_total = {}
	-- body
	for cards_index = 1,5 do
		log.info("user_cards_idx is  [%d]",user_cards_idx)
		local cards_ = nil
		local cards = {}
		log.info("Goocards is [%d] prob is [%d]" , Goocards, prob)
		if prob <  Goocards then
			-- 做牌型
			log.info("get goold cards")
			 cards_ = { true, true , true , false , false }
			self:get_rand_key()
			local a, b , c , d = random.boost_key(5,self.rand_key), random.boost_key(5,self.rand_key + 1), random.boost_key(5,self.rand_key + 2), random.boost_key(5,self.rand_key + 3)

			log.info("a is [%d] b is [%d] c is [%d] d is [%d]" , a, b ,c ,d)
			if a ~= b then
				cards_[a] ,cards_[b] = cards_[b] ,cards_[a]
			end
			if c ~= d then
				cards_[c] ,cards_[d] = cards_[d] ,cards_[c]
			end
		else
			-- 不做牌型
			cards_ = { false , false , false , false , false }
		end

		local haveTenCards = true
		for i = 1,5 do
			local idx = 0
			if cards_[i] then
				if setCount - user_cards_idx >= SYS_CARDS_VALUE then
					self:get_rand_key()
					idx = random.boost_key(SYS_CARDS_VALUE,setCount - user_cards_idx,self.rand_key)
				else
					if haveTenCards then
						local x = 1
						idx = 0
						while( x < setCount - user_cards_idx and idx == 0 ) do
							if self.t_card_set[x] >= 36 then
								idx = x
							end
							x = x + 1
						end
						if idx == 0 then
							haveTenCards = false
						end
					end

					if idx == 0 then
						self:get_rand_key()
						idx = random.boost_key(1,setCount - user_cards_idx,self.rand_key)
					end
				end
			else
				self:get_rand_key()
				idx = random.boost_key(1,setCount - user_cards_idx,self.rand_key)
			end
			local card = self.t_card_set[idx]
			table.insert(cards, card)
			self.t_card_set[idx] = self.t_card_set[getNum(self.t_card_set) - user_cards_idx]
			self.t_card_set[getNum(self.t_card_set) - user_cards_idx] = card
			user_cards_idx = user_cards_idx + 1
		end
		-- table.insert(cards_total , cards)
		cards_total[cards_index] = cards
	end
	return cards_total, user_cards_idx
end
function banker_table:send_player_cards()

	--for _guid, b_player in pairs(self.b_player) do
	--	local player = self:get_player(b_player.chair)
	--	if player.money < self.room_:get_room_limit() then
	--		player:forced_exit()
	--		self.b_player[player.guid] = nil
	--		self.b_player_count = self.b_player_count - 1
	--		if self.b_player_count < 2 then
	--			self.b_table_busy = 0
	--			self.b_status = STATUS_SEND_CARDS
	--		end
	--		if self.b_player_count < 1 then
	--			self:reset()
	--		end
	--	end
	--end

	log.info("game start  time [%s]",tostring(get_second_time()))
	self.b_status = STATUS_SEND_CARDS
	self.table_game_id = self:get_now_game_id()
	self:next_game()
	self.game_log = {
        table_game_id = self.table_game_id,
        start_game_time = os.time(),
        bottom_bet  = self.b_bottom_bet,
        banker = {},
        banker_contend = {},
        players = {},
    }

	local notify = {}
	notify.pb_player = {}
	notify.pb_table = {
		state = self.b_status,
		bottom_bet = self.b_bottom_bet,
	}

	for _guid, b_player in pairs(self.b_player) do
		local player = self:get_player(b_player.chair)
		table.insert(notify.pb_player, {
			guid = _guid,
			chair = b_player.chair,
			name = player.nickname,
			icon =  player:get_header_icon(),
			money = player:get_money(),
			ip_area = player.ip_area
		})
		self.game_log.banker_contend[b_player.chair] = -1
		self.game_log.players[b_player.chair] = {
			nickname = player.nickname,
			chair = b_player.chair,
			money_old = player:get_money()
		}

		local str = string.format("incr %s_%d_%d_players",def_game_name,def_first_game_type,def_second_game_type)
		log.info(str)
		redis_command(str)
	end
	self:get_rand_key()
	local this_time_exchange_coeff = random.boost_key(0,100,self.rand_key)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
-- local _idx = 1

	self:get_rand_key()
	local prob = random.boost_key(0,100,self.rand_key)
	local Goocards = SYSTEM_BEAST_PROB + random.boost_key(0,SYSTEM_FLOAT_PROB,self.rand_key + 1)
	local setCount = getNum(self.t_card_set) or SYS_CARDS_NUM
	local cards, user_cards_idx = self:get_cards()

	for _key, _player in pairs(notify.pb_player) do
		self.b_player[_player.guid].cards = cards[_player.chair]
	end
	--黑名单检查
	self:check_black_user(cards)

	for _key, _player in pairs(notify.pb_player) do
		notify.pb_table.chair = _player.chair
		self.b_player[_player.guid].cards = cards[_player.chair]
		self.game_log.players[_player.chair].cards = self.b_player[_player.guid].cards
		log.info("1111111111player is [%d] cards [%s]" , _player.guid , table.concat( self.b_player[_player.guid].cards, ", "))
		--
		--log.info("user_cards_idx is  [%d]",user_cards_idx)
		--notify.pb_table.chair = _player.chair
		--local cards_ = nil
		--log.info("Goocards is [%d] prob is [%d]" , Goocards, prob)
		--if prob <  Goocards then
		--	-- 做牌型
		--	log.info("get goold cards")
		--	 cards_ = { true, true , true , false , false }
		--	self:get_rand_key()
		--	local a, b , c , d = random.boost_key(5,self.rand_key), random.boost_key(5,self.rand_key + 1), random.boost_key(5,self.rand_key + 2), random.boost_key(5,self.rand_key + 3)
--
		--	log.info("a is [%d] b is [%d] c is [%d] d is [%d]" , a, b ,c ,d)
		--	if a ~= b then
		--		cards_[a] ,cards_[b] = cards_[b] ,cards_[a]
		--	end
		--	if c ~= d then
		--		cards_[c] ,cards_[d] = cards_[d] ,cards_[c]
		--	end
		--else
		--	-- 不做牌型
		--	cards_ = { false , false , false , false , false }
		--end
--
		--local haveTenCards = true
		--for i = 1,5 do
		--	local idx = 0
		--	if cards_[i] then
		--		if setCount - user_cards_idx >= SYS_CARDS_VALUE then
		--			self:get_rand_key()
		--			idx = random.boost_key(SYS_CARDS_VALUE,setCount - user_cards_idx,self.rand_key)
		--		else
		--			if haveTenCards then
		--				--log.info("=================================================")
		--				local x = 1
		--				idx = 0
		--				while( x < setCount - user_cards_idx and idx == 0 ) do
		--					if self.t_card_set[x] >= 36 then
		--						idx = x
		--					end
		--					x = x + 1
		--				end
		--				--log.info("=================================================end[%d]",idx)
		--				if idx == 0 then
		--					haveTenCards = false
		--				end
		--			end
--
		--			if idx == 0 then
		--				self:get_rand_key()
		--				idx = random.boost_key(1,setCount - user_cards_idx,self.rand_key)
		--			end
--
		--			--if idx == 0 and i == 1 then
		--			--	idx = random.boost(1,setCount - user_cards_idx)
		--			--elseif idx == 0 then
		--			--	local upCards = get_value(self.b_player[_player.guid].cards[i - 1]) + 1
		--			--	log.info("1. upCards[%d][%d] ",self.b_player[_player.guid].cards[i - 1] , upCards )
		--			--	local x = 1
		--			--	while( x < setCount - user_cards_idx and idx == 0 ) do
		--			--		log.info("x is [%d]",x)
		--			--		local thisCards = get_value(self.t_card_set[x]) + 1
		--			--		log.info("2. thisCards[%d][%d] ",self.t_card_set[x] , thisCards )
		--			--		if thisCards + upCards == 10 then
		--			--			log.info("3. upCards[%d][%d] t_card_set[%d][%d]",self.b_player[_player.guid].cards[i - 1] , upCards , self.t_card_set[x] , thisCards )
		--			--			idx = x
		--			--		end
		--			--		x = x + 1
		--			--	end
		--			--end
		--		end
		--	else
		--		self:get_rand_key()
		--		idx = random.boost_key(1,setCount - user_cards_idx,self.rand_key)
		--		--log.info("tt i is [%d] idx is [%d]" ,i, idx)
		--	end
		--	local card = self.t_card_set[idx]
		--	table.insert(self.b_player[_player.guid].cards, card)
		--	self.t_card_set[idx] = self.t_card_set[getNum(self.t_card_set) - user_cards_idx]
		--	self.t_card_set[getNum(self.t_card_set) - user_cards_idx] = card
		--	user_cards_idx = user_cards_idx + 1
		--	--log.info("self.t_card_set is [%s]",table.concat(self.t_card_set,","))
		--end
		--self.game_log.players[_player.chair].cards = self.b_player[_player.guid].cards
		--log.info("1111111111player is [%d] cards [%s]" , _player.guid , table.concat( self.b_player[_player.guid].cards, ", "))
		-- ]]
--special cards type
-- if DEBUG_MODE then
-- 	for i = 1,5 do
-- 		self.b_player[_player.guid].cards[i] = self.t_card_set[_idx]
-- 		_idx = _idx + 1
-- 	end
-- end

		if this_time_exchange_coeff < EXCHANGE_COEFF then  --按照一定概率换，不要所有都换导致玩家能评估到有牛就有牛，没牛就没牛
			local cards_num_total = getNum(self.b_player[_player.guid].cards)
			if cards_num_total == 5 then
				local orig_cards = {}
				for i_index = 1,cards_num_total do
					table.insert(orig_cards,self.b_player[_player.guid].cards[i_index])
				end
				log.info("guid [%d]----------------orig_cards---->[%s]" , _player.guid ,table.concat(orig_cards, ", "))
				local ox_type_,value_list_,color_, extro_num_, sort_cards_ = get_cards_type(orig_cards)
				if ox_type_ >= BANKER_CARD_TYPE_ONE then --有牛就将能凑牛的牌放在前面可观看的4张中
					if sort_cards_ ~= nil and getNum(sort_cards_) == 5 then
						log.info("222222222222 before exchange cards:player guid[%d],ox_type_[%d] sort_cards_[%s]" , _player.guid ,ox_type_, table.concat(sort_cards_, ", "))
						--交换牌顺序
						self.b_player[_player.guid].cards = {}
						for i_key = 1,5 do
							table.insert(self.b_player[_player.guid].cards,sort_cards_[i_key])
						end
						log.info("333333333333333 after exchange cards:player is [%d]  cards [%s]" , _player.guid , table.concat( self.b_player[_player.guid].cards, ", "))
					end
				end
			end
		end

		log.info("444444player is [%d] cards [%s]" , _player.guid , table.concat( self.b_player[_player.guid].cards, ", "))
		notify.cards = {}
		for i = 1,4 do
			notify.cards[i] = self.b_player[_player.guid].cards[i]
		end
		notify.cards[5] = -1
		local player = self:get_player(_player.chair)
		send2client_pb(player, "SC_BankerSendCards", notify)
		send2client_pb(player, "SC_BankerBasicBetTimesOptions", {bet_options = bet_times_option})

	end



	--运算所有玩家牌类型
	self:run_cards_type()
	--计算机器人是否为最大牌型
	local max_chair_id, mix_chair_id = self:robot_start_game()
	local r = random.boost_integer(1,100)
	local b_change_cards = false
	if (r < self.robot_change_card) and self.robot_switch ~= 0 then
		b_change_cards = true
	end
	local now_cards_num = setCount - user_cards_idx
	if b_change_cards then
		local b_change_max = false
		local b_change_mix = false
		for _guid, b_player in pairs(self.b_player) do
			if next(b_player.cards) ~= nil then
				--最大牌是玩家
				local v = self:get_player(b_player.chair)
				if v and v.is_player and v.chair_id ==  max_chair_id then
					log.info("change____player____cards_____begin:")
					log.info(table.concat(self.b_player[v.guid].cards, ','))
					b_change_mix,self.t_card_set = get_mix_card(self.t_card_set, self.b_player[v.guid].cards, now_cards_num)
					log.info("change____player____cards_____end:", b_change_mix)
					log.info(table.concat(self.b_player[v.guid].cards, ','))
				--最小牌是机器人
				elseif  v and v.is_player == false  and v.chair_id ==  mix_chair_id then
					log.info("change____Robot____cards_____begin:")
					log.info(table.concat(self.b_player[v.guid].cards, ','))
					b_change_max,self.t_card_set = get_max_card(self.t_card_set, self.b_player[v.guid].cards, now_cards_num)
					log.info("change____Robot____cards_____end:", b_change_max)
					log.info(table.concat(self.b_player[v.guid].cards, ','))
				end
			end
		end
		if b_change_mix or b_change_max then
			self:run_cards_type()
		end
	end
	local check_list = {}
	for _guid, b_player in pairs(self.b_player) do
		--tmp added for b_player error
		if next(b_player.cards) ~= nil then
			for i = 1, 5 do
				table.insert(check_list, b_player.cards[i])
			end
		end
	end

	for _A, check_card_A in ipairs (check_list) do
		for _B, check_card_B in ipairs (check_list) do
			if check_card_B == check_card_A and _A ~= _B then
				log.error("error cards A:[%d][%d][%d]", _A ,  _B, check_card_A)
				log.error(table.concat(check_list, ','))
			end
		end
	end

	for _A, check_card_A in ipairs (check_list) do
		for i = 1, now_cards_num  do
			if self.t_card_set[i] == check_card_A then
				log.error("error cards B:[%d]" , check_card_A)
				log.error(table.concat(check_list, ','))
				log.error(table.concat(self.t_card_set, ','))
			end
		end
	end

	self.b_status = STATUS_CONTEND_BANKER
	self.b_timer = get_second_time() + STAGE_INTERVAL_TIME
end

--运算所有玩家牌类型
function banker_table:run_cards_type()
	for _guid, b_player in pairs(self.b_player) do
		--tmp added for b_player error
		if next(b_player.cards) ~= nil then
			--算出牌型，倍数
			local ox_type_,value_list_,color_, extro_num_, sort_cards_ = get_cards_type(b_player.cards)
			local times = get_type_times(ox_type_,extro_num_)
			self.b_ret[_guid] =
			{
				guid = _guid,
				ox_type = ox_type_,
				val_list = value_list_,
				color = color_,
				extro_num = extro_num_,
				cards_times = times
			}

			if ox_type_ == BANKER_CARD_TYPE_ONE then
				--牛1 - 牛9·
				self.b_player[_guid].cards_type = BANKER_CARD_TYPE_NONE + extro_num_
				self.b_player[_guid].sort_cards = sort_cards_
			elseif ox_type_ == BANKER_CARD_TYPE_TEN then
				self.b_player[_guid].cards_type = ox_type_
				self.b_player[_guid].sort_cards = sort_cards_
			else
				self.b_player[_guid].cards_type = ox_type_
			end
		end
	end
end
function banker_table:getNum(arraylist)
	-- body
	local iNum = 0
	for _,v in pairs(arraylist) do
		iNum = iNum + 1
	end
	return iNum
end

function banker_table:decide_banker()

	log.info("gameid [%s] self.b_contend_count is [%d]",self.table_game_id, getNum(self.b_contend_count))
	--定庄阶段
	self.b_status = STATUS_DICISION_BANKER
	self.b_total_time = 0
	local banker_candidate = {}		--抢庄的候选人

	if getNum(self.b_contend_count) == 0 then
		-- 没人抢庄
		log.info("gameid [%s] no one contend count ~!",self.table_game_id)
		for _guid, b_player in pairs(self.b_player) do
			--未表态，群发默认不抢
			self.b_player[_guid].ratio = -1
			local msg = {
				chair = b_player.chair,
				ratio = -1
			}
			self:t_broadcast("SC_BankerPlayerContend", msg)
			self.game_log.banker_contend[b_player.chair] = 1
			log.info("not find  player contend banker.")
			local b_contend_data = {
				guid = _guid,
				ratio = 1,
				chair = b_player.chair,
			}
			table.insert(banker_candidate, b_contend_data)
		end
	else
		for _,v in pairs(self.b_contend_count) do
			if #banker_candidate == 0 then
				table.insert(banker_candidate,v)
			elseif banker_candidate[1].ratio == v.ratio then
				table.insert(banker_candidate,v)
			elseif banker_candidate[1].ratio < v.ratio then
				banker_candidate = {}
				table.insert(banker_candidate,v)
			end
		end
	end

	-- local b_contend_data = {
	-- 	guid = player.guid,
	-- 	ratio = ratio,
	-- 	chair = player.chair_id,
	-- }
	--for _guid, b_player in pairs(self.b_player) do
	--	--tmp added for b_player errors
	--	if b_player and next(b_player.cards) ~= nil then
	--		if b_player.ratio == 0 then
	--			b_player.ratio = -1
	--		end
	--		if self.b_contend_count > 0 then
	--			if getNum(banker_candidate) == 0 then
	--				banker_candidate[1] = _guid
	--			else
	--				if b_player.ratio > self.b_player[banker_candidate[1]].ratio then
	--					banker_candidate[1]  = _guid
	--					for i = 2, getNum(banker_candidate) do
	--						banker_candidate[i] = nil
	--					end
	--				elseif b_player.ratio == self.b_player[banker_candidate[1]].ratio then
	--					table.insert(banker_candidate, _guid)
	--				end
	--			end
	--		else
	--			--无人抢庄
	--			table.insert(banker_candidate, _guid)
	--		end
	--
	--		--未表态，群发默认不抢
	--		if b_player.ratio == 0 or  b_player.ratio == -1 then
	--			self.b_player[_guid].ratio = -1
	--			local msg = {
	--				chair = b_player.chair,
	--				ratio = -1
	--			}
	--			self:t_broadcast("SC_BankerPlayerContend", msg)
	--			self.game_log.banker_contend[b_player.chair] = 1
	--			log.info("not find  player contend banker.")
	--		end
	--	else
	--		--tmp added for b_player errors
	--		self.b_player[_guid] = nil
	--	end
	--end

	log.info("banker_candidate is [%d]", getNum(banker_candidate))
	local msg = {}
	if getNum(banker_candidate) > 1 then
		msg.chairs = {}
		for _,v in pairs(banker_candidate) do
			table.insert(msg.chairs, v.chair)
		end

		math.randomseed(tostring(os.time()):reverse():sub(1, 6))
		local idx = random.boost(1, getNum(msg.chairs))

		self.b_banker = {
			chair = banker_candidate[idx].chair,
			guid = banker_candidate[idx].guid,
			ratio = banker_candidate[idx].ratio
		}

		msg.banker_chair = banker_candidate[idx].chair
	else
		-- #banker_candidate == 1
		self.b_banker = {
			chair = banker_candidate[1].chair,
			guid = banker_candidate[1].guid,
			ratio = banker_candidate[1].ratio
		}

		msg.banker_chair = banker_candidate[1].chair
		msg.chairs = { msg.banker_chair }

	end

	if self.b_banker.ratio < 1 then
		self.b_banker.ratio = 1
		self.b_player[self.b_banker.guid].ratio = 1
	end
	msg.banker_ratio = self.b_banker.ratio
	log.info("self.b_banker.ratio = [%d],guid = [%d]", self.b_banker.ratio,self.b_banker.guid)
	self.game_log.banker = self.b_banker

	if DEBUG_MODE then
		print("||||||   decide_banker()  |||||||||")
		dump(msg)
	end

	--闲家最大压注
	local banker_player = self:get_player(self.b_banker.chair)
	local banker_money = banker_player:get_money()
	--self.b_max_bet = math.floor(banker_money / (self.b_player_count - 1))

	self:t_broadcast("SC_BankerChoosingBanker", msg)
	self.b_status = STATUS_BET
	--self.b_timer = get_second_time() + DICISION_BANKER
	--只有一人抢庄时不延时5s给客户端播放动画
	if getNum(self.b_contend_count) == 1 then
		self.b_timer = get_second_time()
	else--抢庄人数大于1时或者都没有人抢庄时加延时给客户端播放动画时间
		self.b_timer = get_second_time() + DICISION_BANKER
	end
	log.info("Cur Banker guid = [%d], ratio = [%d]",self.b_banker.guid,self.b_banker.ratio)
end

function banker_table:show_cards()
	if DEBUG_MODE then
		print("============ test print b_player  ================")
		dump(self.b_player)
		print("============ test print end  ================")
	end

	--摊牌阶段
	self.b_status = STATUS_SHOW_CARD
	self.b_total_time = 0
	--未下注的，默认下最低倍
	for _guid, b_player in pairs(self.b_player) do
		--tmp added for b_player error
		if next(b_player.cards) ~= nil then
			if b_player.bet == 0 and _guid ~= self.b_banker.guid then
				self.b_player[_guid].bet = bet_times_option[1] * self.b_bottom_bet * self.b_banker.ratio

				local msg = {
					chair = b_player.chair,
					bet_money = self.b_player[_guid].bet,
					bet_times = bet_times_option[1] --默认的该场次的最低倍数
				}
				self:t_broadcast("SC_BankerPlayerBet", msg)
				self.game_log.players[b_player.chair].bet_times = msg.bet_times
				self.game_log.players[b_player.chair].bet = self.b_player[_guid].bet
			end

			--[[算出牌型，倍数
			local ox_type_,value_list_,color_, extro_num_, sort_cards_ = get_cards_type(b_player.cards)
			local times = get_type_times(ox_type_,extro_num_)
			self.b_ret[_guid] =
			{
				guid = _guid,
				ox_type = ox_type_,
				val_list = value_list_,
				color = color_,
				extro_num = extro_num_,
				cards_times = times
			}

			if ox_type_ == BANKER_CARD_TYPE_ONE then
				--牛1 - 牛9·
				self.b_player[_guid].cards_type = BANKER_CARD_TYPE_NONE + extro_num_
				self.b_player[_guid].sort_cards = sort_cards_
			elseif ox_type_ == BANKER_CARD_TYPE_TEN then
				self.b_player[_guid].cards_type = ox_type_
				self.b_player[_guid].sort_cards = sort_cards_
			else
				self.b_player[_guid].cards_type = ox_type_
			end]]

			self.game_log.players[b_player.chair].cards_type = self.b_player[_guid].cards_type
			self.game_log.players[b_player.chair].cards_info = self.b_ret[_guid]
		else
			self.b_player[_guid] = nil
		end
	end

	--看到自己的牌
	local msg = {
		countdown = SHOWCARD_TIME,
		total_time = SHOWCARD_TIME,
	}
	for _guid, b_player in pairs(self.b_player) do
		msg.cards = b_player.cards
		msg.cards_type = b_player.cards_type

		local player = self:get_player(b_player.chair)
		if player then
			send2client_pb(player, "SC_BankerShowOwnCards", msg)
		end
	end

	self.b_status = STATUS_SHOW_CARD_END
	self.b_timer = get_second_time() + SHOWCARD_TIME
	self.b_total_time = SHOWCARD_TIME
end

function banker_table:send_result()
	self.banker_player_record = {}
	self.b_total_time = 0
	for _guid, b_player in pairs(self.b_player) do

		local str = string.format("decr %s_%d_%d_players",def_game_name,def_first_game_type,def_second_game_type)
		log.info(str)
		redis_command(str)
		--tmp added for b_player errors
		if b_player.show_card == 0 and next(b_player.cards) ~= nil then

			local msg = {
				chair = b_player.chair,
				cards_type = b_player.cards_type,
			}

			if msg.cards_type > BANKER_CARD_TYPE_NONE and msg.cards_type < BANKER_CARD_TYPE_FOUR_KING then
				msg.flag = 1
				msg.cards = self.b_player[_guid].sort_cards and self.b_player[_guid].sort_cards or self.b_player[_guid].cards
			else
				msg.flag = 2
				msg.cards = self.b_player[_guid].cards
			end

			self:t_broadcast("SC_BankerShowCards", msg)
		end
	end

	-- 下注流水日志
	for _,player in pairs(self.b_player) do
		self:player_bet_flow_log(player,player.bet)
	end

	self.b_status = STATUS_SHOW_DOWN
	print("send_result......")
	local notify = {}
	notify.pb_table = {
		state = self.b_status,
		bottom_bet = self.b_bottom_bet,
	}
	notify.pb_player = {}

	local banker_result = self.b_ret[self.b_banker.guid]

	local banker_player = self:get_player(self.b_banker.chair)
	local banker_old_money = banker_player.money
	local player_bankruptcy_flag = {} --记录玩家是否破产标记
	player_bankruptcy_flag[banker_player.guid] = 1 --庄家默认不破产
	local player_result  = {} --玩家应该赢或输的钱
	local banker_win_lose_money = 0
	local banker_win_money = 0
	local banker_lose_money = 0
	for _guid, b_player in pairs(self.b_player) do
		-- 先算出应该 输胜金钱总数
		if _guid ~= self.b_banker.guid and b_player.cards then
			local l_player = self:get_player(b_player.chair)
			local win = compare_cards(self.b_ret[_guid], banker_result)
			local s_old_money = l_player.money
			player_bankruptcy_flag[l_player.guid] = 1 --默认玩家不破产
			if win == true then
				local win_times_ = get_cards_odds(self.b_ret[_guid].cards_times)
				local win_money_ = b_player.bet * win_times_
				-- 赢
				if s_old_money < win_money_ then
					win_money_ = s_old_money
				end
				player_result[l_player.guid] = win_money_
                banker_lose_money = banker_lose_money + win_money_
				banker_win_lose_money = banker_win_lose_money + win_money_ --大于0是庄家输了好多钱，小于0是庄家赢了好多钱
				log.info("1111player[%d] betmoney = [%d],win_money_ = [%d] banker_win_lose_money = [%d]",l_player.guid,b_player.bet,win_money_,banker_win_lose_money)
			else
				local lose_times_ = get_cards_odds(banker_result.cards_times)
				local lose_money_ = b_player.bet * lose_times_
				-- 输
				if s_old_money < lose_money_ then
					lose_money_ = s_old_money
					player_bankruptcy_flag[l_player.guid] = 2 --玩家不够赔，破产
				end
				player_result[l_player.guid] = lose_money_
				banker_win_money = banker_win_money + lose_money_
				banker_win_lose_money = banker_win_lose_money - lose_money_
				log.info("2222player[%d] betmoney = [%d],lose_money_ = [%d] banker_win_lose_money = [%d]",l_player.guid,b_player.bet,lose_money_,banker_win_lose_money)
			end
		end
	end
	--local banker_lose_money = 0
	--if banker_win_lose_money > 0 then		-- 输的钱 大于0
	--	-- 判断 输掉的钱 是否大于 庄家自己身上的钱
	--	if banker_win_lose_money > banker_old_money then
	--		banker_lose_money = banker_old_money
	--	end
	--end
    log.info("banker_lose_money [%d] banker_win_money [%d] banker_old_money [%d] banker_win_lose_money[%d]", banker_lose_money, banker_win_money, banker_old_money, banker_win_lose_money)
	local lose_coeff = 0.0  --庄家输的比例
	local win_coeff = 0.0   --庄家赢的比例
	if banker_win_lose_money > 0 and banker_win_lose_money > banker_old_money then  --庄家输
		lose_coeff = (banker_old_money + banker_win_money) / banker_lose_money
		player_bankruptcy_flag[banker_player.guid] = 2 --庄家不够赔,破产
	end
	if banker_win_lose_money < 0 and (-banker_win_lose_money) > banker_old_money then --庄家赢
		win_coeff = (banker_old_money + banker_lose_money) / banker_win_money
	end
	log.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~lose_coeff = [%f] win_coeff = [%f]",lose_coeff,win_coeff)


	for _guid, b_player in pairs(self.b_player) do
		if _guid ~= self.b_banker.guid and b_player.cards then
			local l_player = self:get_player(b_player.chair)
			local pb_player = {}
			local s_type = 1  -- default loss ,2 win
			local s_old_money = l_player.money
			local win = compare_cards(self.b_ret[_guid], banker_result)
			local banker_ox_player_stdard_award = 0

			if win == true then
				s_type = 2
				local win_money = player_result[l_player.guid]
				log.info("3333player guid[%d] win_money = [%d] banker_win_lose_money = [%d] banker_old_money = [%d]",l_player.guid,win_money,banker_win_lose_money,banker_old_money)
				if banker_old_money < 2 then
					win_money = 0 			-- 异常情况 玩家作弊
					log.error("player [%d] Cheat" , _guid)
				else
					if banker_win_lose_money > 0 and banker_win_lose_money > banker_old_money then
					--  按比例获得 金币
						win_money =  math.floor(win_money * lose_coeff)
						log.info("4444banker_ox:guid[%d] win_money [%d] banker_old_money [%d] banker_win_lose_money [%d]",_guid,win_money ,banker_old_money ,banker_win_lose_money)
					end
				end

				if s_old_money < win_money then
					log.info("~~~~~~s_old_money = [%d] win_money = [%d]",s_old_money,win_money)
					win_money = s_old_money
					log.info("------s_old_money = [%d] win_money = [%d]",s_old_money,win_money)
				end
				log.info("55555player[%d] betmoney = [%d],win_money = [%d] banker_win_lose_money = [%d]",l_player.guid,b_player.bet,win_money,banker_win_lose_money)
				local pb_tax = win_money * self.b_tax
				if pb_tax < 1 then
					pb_tax = 0
				else
					pb_tax = math.floor(pb_tax + 0.5)
				end

				pb_player = {
					chair = b_player.chair,
					money = 0,
					tax = pb_tax,
					victory = 1,
					increment_money = win_money - pb_tax,
					bankruptcy = player_bankruptcy_flag[l_player.guid],--默认不破产
				}
				if self.room_.tax_show_ == 0 then --1显示税收，0不显示税收
					pb_player.tax = 0
				end

				if l_player then
					l_player:add_money(
						{{ money_type = ITEM_PRICE_TYPE_GOLD,
						money = pb_player.increment_money }},
						LOG_MONEY_OPT_TYPE_BANKER_OX
					)
					pb_player.money = l_player:get_money()

					if self:islog(l_player.guid) then
						self:player_money_log(l_player,s_type,s_old_money,pb_tax,pb_player.increment_money,self.table_game_id)
					end
				end

				self.b_pool = self.b_pool - win_money
				self.game_log.players[b_player.chair].tax = pb_tax
				banker_ox_player_stdard_award = pb_player.increment_money
				if banker_ox_player_stdard_award >= BANKER_OX_GRAND_PRICE_BASE and l_player.is_player ~= false then
					log.info("player guid[%d] nickname[%s]in banker ox game earn money[%d] upto [%d],broadcast to all players.",l_player.guid,l_player.nickname,banker_ox_player_stdard_award,BANKER_OX_GRAND_PRICE_BASE)
					banker_ox_player_stdard_award = banker_ox_player_stdard_award / 100
					broadcast_world_marquee(def_first_game_type,def_second_game_type,0,l_player.nickname,banker_ox_player_stdard_award)
				end
			else --lose
				s_type = 1
				local lose_money = player_result[l_player.guid]
				log.info("~~~~~~~~~player[%d]:will lose lose_money = [%d] player old money = [%d]",l_player.guid,lose_money,s_old_money)
				if banker_win_lose_money < 0 and (-banker_win_lose_money) > banker_old_money then
				--  按比例获得 金币
					lose_money =  math.floor(lose_money * win_coeff)
					log.info("66666banker_ox:guid[%d] lose_money [%d] banker_old_money [%d] banker_win_lose_money [%d]",_guid,lose_money ,banker_old_money ,banker_win_lose_money)
				end

				if s_old_money < lose_money then
					log.info("~~~~~~s_old_money = [%d] lose_money = [%d]",s_old_money,lose_money)
					lose_money = s_old_money
					log.info("----->s_old_money = [%d] lose_money = [%d]",s_old_money,lose_money)
				end
				log.info("77777player[%d] betmoney = [%d],acturl lose_money = [%d] banker_win_lose_money = [%d]",l_player.guid,b_player.bet,lose_money,banker_win_lose_money)
				pb_player = {
					chair = b_player.chair,
					money = 0,
					tax = 0,
					victory = 2,
					increment_money = -lose_money,
					bankruptcy = player_bankruptcy_flag[l_player.guid],
				}
				if l_player then
					l_player:cost_money(
						{{money_type = ITEM_PRICE_TYPE_GOLD, money = -pb_player.increment_money}},
						LOG_MONEY_OPT_TYPE_BANKER_OX,true
					)
					pb_player.money = l_player:get_money()
					if self:islog(l_player.guid) then
						self:player_money_log(l_player,s_type,s_old_money,0,pb_player.increment_money,self.table_game_id)
					end
					self:save_player_collapse_log(l_player)
				end

				self.b_pool = self.b_pool - pb_player.increment_money	-- add increment_money

			end

			local player_record = {
				guid = l_player.guid,
				header_icon = l_player:get_header_icon(),
				nick_name = l_player.nickname,
				cards_type = b_player.cards_type,
				money_change = pb_player.increment_money,
			}
			log.info("record: player[%d] header_icon[%d] nickname[%s] cards_type[%d] money_change[%d]",player_record.guid,player_record.header_icon,player_record.nick_name,player_record.cards_type,player_record.money_change)
			table.insert(self.banker_player_record,player_record)
			table.insert(notify.pb_player, pb_player)
			self.game_log.players[b_player.chair].increment_money = pb_player.increment_money
			self.game_log.players[b_player.chair].money_new = pb_player.money
		end
	end

	local pb_banker = {
		chair = self.b_banker.chair,
		money = 0,
		tax = 0,
		victory = 0,
		increment_money = 0,
		bankruptcy = player_bankruptcy_flag[banker_player.guid], --默认不破产
	}

	--banker add or cost money
	local l_player = self:get_player(self.b_banker.chair)
	local s_type = 1  -- default loss ,2 win
	local s_old_money = l_player.money
	local banker_ox_banker_stdard_award = 0
	log.info("==================>b_pool = [%d] banker_win_lose_money = [%d]",self.b_pool,banker_win_lose_money)
	if self.b_pool > 0 and banker_win_lose_money < 0 then
		log.info("88888b_pool = [%d] banker_win_lose_money = [%d]",self.b_pool,banker_win_lose_money)
		pb_banker.victory = 1
		s_type = 2
		pb_banker.tax = math.floor(self.b_pool *  self.b_tax + 0.5)
		pb_banker.increment_money = self.b_pool - pb_banker.tax
		log.info("99999player[%d] increment_money = [%d] tax = [%d]",l_player.guid,pb_banker.increment_money,pb_banker.tax)
		if pb_banker.increment_money > s_old_money then
			log.info("00000guid[%d] banker win_money [%d] s_old_money[%d]",l_player.guid,pb_banker.increment_money ,s_old_money)
			pb_banker.increment_money = s_old_money
		end
		log.info("aaaplayer[%d] increment_money = [%d] s_old_money = [%d]",l_player.guid,pb_banker.increment_money,s_old_money)
		if l_player then
			l_player:add_money(
				{{ money_type = ITEM_PRICE_TYPE_GOLD,
				money = pb_banker.increment_money }},
				LOG_MONEY_OPT_TYPE_BANKER_OX
			)
			pb_banker.money = l_player:get_money()
			if self:islog(l_player.guid) then
				self:player_money_log(l_player,s_type,s_old_money,pb_banker.tax,pb_banker.increment_money,self.table_game_id)
			end
		end

		self.game_log.players[self.b_banker.chair].tax = pb_banker.tax
		self.game_log.banker.tax = pb_banker.tax
		if self.room_.tax_show_ == 0 then
			pb_banker.tax = 0 --不显示
		end
		banker_ox_banker_stdard_award = pb_banker.increment_money
		if banker_ox_banker_stdard_award >= BANKER_OX_GRAND_PRICE_BASE and l_player.is_player ~= false then
			log.info("player guid[%d] nickname[%s]in banker ox game earn money[%d] upto [%d],broadcast to all players.",l_player.guid,l_player.nickname,banker_ox_banker_stdard_award,BANKER_OX_GRAND_PRICE_BASE)
			banker_ox_banker_stdard_award = banker_ox_banker_stdard_award / 100
			broadcast_world_marquee(def_first_game_type,def_second_game_type,0,l_player.nickname,banker_ox_banker_stdard_award)
		end
	else
		pb_banker.victory = 2
		s_type = 1
		pb_banker.increment_money = self.b_pool
		local lose_money = -self.b_pool
		-- -pb_banker.increment_money -self.b_player[self.b_banker.guid].bet 庄家不下注
		log.info("ccccguid[%d] b_pool = [%d] banker_ox.increment_money = [%d] lose_money = [%d]",l_player.guid,self.b_pool,pb_banker.increment_money,lose_money)
			if DEBUG_MODE then
				print("||||| resut lost_money: ",lose_money)
				print("|||  pb_banker  |||")
				dump(pb_banker)
			end

		if l_player then
			pb_banker.money = l_player:get_money()
			if lose_money > pb_banker.money then
				lose_money = pb_banker.money
			end
			if lose_money ~= 0 then
				l_player:cost_money(
					{{money_type = ITEM_PRICE_TYPE_GOLD, money = lose_money}},
					LOG_MONEY_OPT_TYPE_BANKER_OX,true
				)
			end
			pb_banker.money = pb_banker.money - lose_money
			if self:islog(l_player.guid) then
				self:player_money_log(l_player,s_type,s_old_money,0,-lose_money,self.table_game_id)
			end
			self:save_player_collapse_log(l_player)
		end
	end

	local banker_record = {
				guid = l_player.guid,
				header_icon = l_player:get_header_icon(),
				nick_name = l_player.nickname,
				cards_type = self.b_player[l_player.guid].cards_type,
				money_change = pb_banker.increment_money,
			}
	log.info("record: banker[%d] header_icon[%d] nickname[%s] cards_type[%d] money_change[%d]",banker_record.guid,banker_record.header_icon,banker_record.nick_name,banker_record.cards_type,banker_record.money_change)
	table.insert(self.banker_player_record,banker_record)
	table.sort(self.banker_player_record, function (a, b)
		if a.money_change == b.money_change then
			return a.guid < b.guid
		else
			return a.money_change > b.money_change
		end
	end)
	table.insert(notify.pb_player, pb_banker)
	self.game_log.players[self.b_banker.chair].increment_money = pb_banker.increment_money
	self.game_log.players[self.b_banker.chair].money_new = pb_banker.money
	self.game_log.banker.increment_money = pb_banker.increment_money
	self.game_log.banker.money_new = pb_banker.money_new

	self:t_broadcast("SC_BankerGameEnd", notify)
	self.b_end_player = notify.pb_player

		if DEBUG_MODE then
			print("|||  send_resut()  |||")
			dump(notify)
		end


	--gameLog
	self.game_log.end_game_time = os.time()
	local s_log = json.encode(self.game_log)
	log.info(s_log)

	--判断有机器人时是否存储日志
	local is_save_log = true
	if self.robot_switch ~= 0 then
		if self.robot_islog == false then
			is_save_log = false
		end
	end
	if is_save_log then
		self:save_game_log(self.game_log.table_game_id,self.def_game_name,s_log,self.game_log.start_game_time,self.game_log.end_game_time)
	end
	log.info("game finish~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!")
	self:reset()
	self.b_status = STATUS_OVER
	self.b_timer = get_second_time() + END_TIME
	local room_limit = self.room_:get_room_limit()
	for i,player in pairs(self.players) do
		if player and player.banker_enterflag ~= true then
			player.ready = false
			player.enterTime = get_second_time()
			if  player.in_game == false then
				log.info("player [%d] is offline ",i)
				player:forced_exit()
				log.info("set player[%d] in_game false" ,player.guid)
				player.in_game = false
			else
				player:check_forced_exit(room_limit)
			end
		--else
		--	if player then
		--		self:playerReady(player)
		--	else
		--		log.info("v is nil:"..i)
		--	end
		end
	end

	self:check_single_game_is_maintain()
	self:check_robot_leave()
	log.info("game end ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!")
end


function banker_table:begin_bet()
	local msg = {
		countdown = BET_TIME - 1,
		total_time = BET_TIME - 1,
	}
	self:t_broadcast("SC_BankerPlayerBeginToBet", msg)

	self.b_status = STATUS_BET_END
	self.b_timer = get_second_time() + BET_TIME
	self.b_total_time = BET_TIME
end

function banker_table:begin_to_contend()
	log.info("banker_table:begin_to_contend =========================")
	local msg = {
		countdown = CONTEND_BANKER_TIME - 1,
		total_time = CONTEND_BANKER_TIME - 1
	}
	self:t_broadcast("SC_BankerBeginToContend", msg)

	self.b_status = STATUS_CONTEND_END
	self.b_timer = get_second_time() + CONTEND_BANKER_TIME
	self.b_total_time = CONTEND_BANKER_TIME
end

function banker_table:banker_bet(player, msg)
	if self.b_status ~= STATUS_BET_END then
		log.info("b_status[%f]",self.b_status)
		return
	end
	if player == nil then
		log.error("player ===============nil.")
		return
	end

	if self.b_player[player.guid] == nil then
		if player.is_player ~= false then
			log.error("b_player[%d] ===============nil.",player.guid)
		end
		return
	end

	if self.b_banker.guid == player.guid then
		log.warning("banker guid[%d] can't bet money.",player.guid)
		return
	end

--[[
	-- 算出实际下注金额
	msg.bet_money = self.b_bottom_bet * self.b_banker.ratio * msg.bet_times
	local bankerMoney = (self:get_player(self.b_banker.chair)):get_money() 	-- 庄家身上的钱
	local playerPayMoney = math.ceil(bankerMoney / (self.b_player_count - 1))	-- 每个玩家实际可下注金额

	log.info("banker_bet player[%d] bankerMoney [%s] playerPayMoney[%s] #self.b_player[%d] msg.bet_times [%s]",player.guid,tostring(bankerMoney) ,tostring(playerPayMoney) , self.b_player_count, tostring(msg.bet_times))

	local l_money = player:get_money()										-- 玩家自己身上的钱
	local self_bet_max = l_money

	if l_money > playerPayMoney then
		self_bet_max = playerPayMoney				--取两个数值中 最小的一个
	end

	log.info("banker_bet player[%d] playerPayMoney [%s] l_money[%s] self_bet_max[%s] msg.bet_money[%s]",player.guid,tostring(playerPayMoney) ,tostring(l_money) ,tostring(self_bet_max) ,tostring(msg.bet_money))

	if msg.bet_money > self_bet_max then
		local bet_times = 2
		local bet_m = 0
		local base_bet = self.b_bottom_bet * self.b_banker.ratio
		while (bet_m < self_bet_max) do
			bet_m = base_bet * bet_times
			bet_times = bet_times + 1
		end
		bet_times = bet_times - 1
		log.info("old bet_money is  [%s] bet_times [%s] " , tostring(msg.bet_money) , tostring(msg.bet_times))
		msg.bet_money = bet_times * base_bet
		msg.bet_times  = bet_times
		log.info("new bet_money is  [%s] bet_times [%d] " , tostring(msg.bet_money) , tostring(msg.bet_times))
	end
--]]

	local cur_player_money = player:get_money()
	log.info("player guid[%d] bet_money = [%d] bet_times = [%d] cur_player_money = [%d] ,banker ratio = [%d]",player.guid,msg.bet_money,msg.bet_times,cur_player_money,self.b_banker.ratio)
	local player_cur_max_times = bet_times_option[1]
	--下注金币 = 闲家下注倍数 × 底注 × 庄家抢庄倍数
	if msg.bet_times == player_cur_max_times then --玩家选择最低倍数始终可选不用判断
		msg.bet_money = msg.bet_times * self.b_bottom_bet * self.b_banker.ratio
	else
		--选择其他倍数时需要判断玩家实际最大可选倍数 < 玩家下注倍数时，则重置玩家下注倍数（置为该场次的实际最大可选倍数的前一个倍数）
		--举例：该场次基础倍数为[5,10,15,20],玩家下注倍数为20倍，但玩家的实际最大倍数为18倍,那么需重置玩家的倍数为15倍
		--最大可选倍数=携带金币/底注/庄家抢庄倍数/4
		local acturl_player_bet_max_times = math.floor(cur_player_money/self.b_bottom_bet/self.b_banker.ratio/4)
		log.info("player guid[%d] bet_times[%d] acturl_player_bet_max_times[%d]",player.guid, msg.bet_times,acturl_player_bet_max_times)
		if msg.bet_times > acturl_player_bet_max_times then
			for i=1,4 do
				if acturl_player_bet_max_times > bet_times_option[i] and acturl_player_bet_max_times < bet_times_option[i+1] then
					msg.bet_times = bet_times_option[i]
					break
				end
			end
		end

		if msg.bet_times ~= bet_times_option[1] and msg.bet_times ~= bet_times_option[2] and msg.bet_times ~= bet_times_option[3] and msg.bet_times ~= bet_times_option[4] then
			log.warning("player guid[%d] bet times[%d] error, will set lowest bet options[%d]",player.guid,msg.bet_times,bet_times_option[1])
			msg.bet_times = bet_times_option[1]
		end
		msg.bet_money = msg.bet_times * self.b_bottom_bet * self.b_banker.ratio
		log.info("player guid[%d] bet_money = [%d] acturl_bet_times = [%d] cur_player_money = [%d] ,banker ratio = [%d], acturl_player_bet_max_times = [%d]",player.guid,msg.bet_money,msg.bet_times,cur_player_money,self.b_banker.ratio,acturl_player_bet_max_times)
	end

	self.b_player[player.guid].bet = msg.bet_money			--下注金额
	self.b_player[player.guid].bet_times  = msg.bet_times
	local msg = {
		chair = player.chair_id,
		bet_money = msg.bet_money,
		bet_times = msg.bet_times,
	}
	log.info("player guid[%d] bet_money = [%s] bet_times=[%s]",player.guid,tostring(msg.bet_money),tostring(msg.bet_times))
	self:t_broadcast("SC_BankerPlayerBet", msg)
	self.game_log.players[player.chair_id].bet = msg.bet_money

	self.b_bet_count[player.guid] = 1
	--self.b_bet_count = self.b_bet_count + 1

	if getNum(self.b_bet_count) == self.b_player_count - 1 then
	--if self.b_bet_count == self.b_player_count - 1 then
		self.b_timer = get_second_time()
	end
end

function banker_table:banker_guess_cards(player)
	if player then --and next(self.b_player[player.guid]) ~= nil
		log.info("player guid = [%d] show cards cur_status = [%d]",player.guid,self.b_status)
		if self:isPlayer(player) and self.b_status >= STATUS_SHOW_CARD then
			local msg = {
				chair = player.chair_id,
				cards = self.b_player[player.guid].cards,
				cards_type = self.b_player[player.guid].cards_type,
			}

			if msg.cards_type > BANKER_CARD_TYPE_NONE and msg.cards_type < BANKER_CARD_TYPE_FOUR_KING then
				msg.flag = 1
				msg.cards = self.b_player[player.guid].sort_cards and self.b_player[player.guid].sort_cards or self.b_player[player.guid].cards
			else
				msg.flag = 2
				msg.cards = self.b_player[player.guid].cards
			end

				if DEBUG_MODE then
					print("|||||   banker_guess_cards()  |||||")
					dump(msg)
				end

			if not self.b_guess_count[player.guid] then
				self:t_broadcast("SC_BankerShowCards", msg)
			end
			self.b_player[player.guid].show_card = 1
			self.b_guess_count[player.guid] = 1
			if getNum(self.b_guess_count) == self.b_player_count then
				self.b_timer = get_second_time()
			end
		end
	end
end

function banker_table:isPlayer( player )
	-- body
	if player then
		for i,v in pairs(self.b_player) do
			if i == player.guid then
				return true
			end
		end
	end
	return false
end
function banker_table:banker_contend(player, ratio)
	if player and player.guid then
		log.info("banker_table:banker_contend ========== player [%d] ratio[%d]" , player.guid, ratio)
	end
	if self.b_status ~= STATUS_CONTEND_END then
		log.info("============status = [%d] status error,return" ,self.b_status)
		return
	end
	if not self:isPlayer(player) then
		if player then
			log.info("banker_contend player is not in game guid[%d]" , player.guid)
		else
			log.info("banker_contend player is nil")
		end
		return
	end
	if ratio < 0 then
		ratio = 0
	end
	if self.b_player[player.guid].ratio ~= -1 then
		log.info("banker_contend player ratio is not nil guid[%d] ratio[%d]" , player.guid , self.b_player[player.guid].ratio)
		return
	end

	local player_curMoney = player:get_money()
	--最大可抢倍数校验
	local cur_max_ratio = math.floor(player_curMoney/self.b_bottom_bet/25)
	log.info("banker_ox:banker_contend ========== player [%d] ratio[%d] curMoney = [%d] cur_max_ratio = [%d]" , player.guid, ratio,player_curMoney,cur_max_ratio)
	if ratio > cur_max_ratio then
		ratio = cur_max_ratio
	end
	--抢庄倍数异常时，默认为1
	if ratio > 4 then
		log.warning("banker_ox:player guid[%d] banker contend expection ratio[%d] will be set ratio = 1" , player.guid, ratio)
		ratio = 1
	end

	self.b_player[player.guid].ratio = ratio
	local msg = {
		chair = player.chair_id,
		ratio = ratio
	}
	local b_contend_data = {
		guid = player.guid,
		ratio = ratio,
		chair = player.chair_id,
	}
	if ratio ~= 0 then
		table.insert(self.b_contend_count , b_contend_data)
	end
	self.player_contend_count[player.guid] = 1 --统计抢庄发话人数,若等于所有在玩玩家人数时，直接进入下个阶段倒计时
	-- self.b_contend_count = self.b_contend_count + 1
	self:t_broadcast("SC_BankerPlayerContend", msg)
	self.game_log.banker_contend[player.chair_id] = ratio
	log.info("-----------self.b_contend_count = [%d] player_contend_count[%d]" ,getNum(self.b_contend_count), getNum(self.player_contend_count))
	if getNum(self.b_contend_count) == self.b_player_count  or getNum(self.player_contend_count) == self.b_player_count then
		self.b_timer = get_second_time()
	end
end


function banker_table:reconnect(player)
	print("---------- reconnect~~~~~~~~~!",player.chair_id,player.guid)
	if self.b_status == STATUS_WAITING then
		return
	end

	player.table_id = self.table_id_
	player.room_id = self.room_.id
	self.b_recoonect[player.guid] = 1
	--send2client_pb(player, "SC_BankerReconnectInfo", notify)
	return
end

function banker_table:reconnect(player)
	log.info("player[%d] reconnect",player.guid)
	local notify = {}
	notify.pb_table = {
		state = math.floor(self.b_status - 1),
		bottom_bet = self.b_bottom_bet,
		chair = player.chair_id
	}
	notify.pb_player = {}

--	if next(self.b_end_player) == nil then
--		for _guid, b_player in pairs(self.b_player) do
--			local l_player = self:get_player(b_player.chair)
--			local pb_player = {
--				guid = _guid,
--				chair = b_player.chair,
--				name = l_player.nickname,
--				icon =  l_player:get_header_icon(),
--				money = l_player:get_money(),
--				ratio = b_player.ratio,
--				position = _guid == self.b_banker.guid and 1 or -1,
--				bet_money = b_player.bet,
--				ip_area = l_player.ip_area,
--				bet_times = b_player.bet_times
--			}
--
--			if _guid == player.guid and next(b_player.cards) ~= nil then
--				if self.b_status < STATUS_SHOW_CARD then
--					pb_player.cards = {}
--					for i=1,4 do
--						pb_player.cards[i] = b_player.cards[i]
--					end
--					pb_player.cards[5] = -1
--				else
--					pb_player.cards = self.b_player[l_player.guid].cards
--				end
--			end
--
--			table.insert(notify.pb_player, pb_player)
--		end
--	else
--		for _key, b_player in pairs(self.b_end_player) do
--			notify.pb_player = b_player
--			local l_player = self:get_player(b_player.chair)
--			notify.pb_player.guid = l_player.guid
--			notify.pb_player.name = l_player.nickname
--			notify.pb_player.icon =  l_player:get_header_icon()
--			notify.pb_player.ratio = self.b_player[l_player.guid].ratio
--			notify.pb_player.position = l_player.guid == self.b_banker.guid and 1 or -1
--			notify.pb_player.bet_money = self.b_player[l_player.guid].bet
--			notify.pb_player.ip_area = l_player.ip_area
--			notify.pb_player.bet_times = self.b_player[l_player.guid].bet_times
--
--			if l_player.guid == player.guid and next(b_player.cards) ~= nil then
--				if self.b_status < STATUS_SHOW_CARD then
--					notify.pb_player.cards = {}
--					for i=1,4 do
--						notify.pb_player.cards[i] = self.b_player[l_player.guid].cards[i]
--					end
--					notify.pb_player.cards[5] = -1
--				else
--					notify.pb_player.cards =self.b_player[l_player.guid].cards
--				end
--			end
--		end
--	end
	for _guid, b_player in pairs(self.b_player) do
		local l_player = self:get_player(b_player.chair)
		local pb_player = {
			guid = _guid,
			chair = b_player.chair,
			name = l_player.nickname,
			icon =  l_player:get_header_icon(),
			money = l_player:get_money(),
			ratio = b_player.ratio,
			position = _guid == self.b_banker.guid and 1 or -1,
			bet_money = b_player.bet,
			ip_area = l_player.ip_area,
			bet_times = b_player.bet_times
		}
		if _guid == player.guid and next(b_player.cards) ~= nil then
			if math.floor(self.b_status - 1) < STATUS_SHOW_CARD then
				pb_player.cards = {}
				for i=1,4 do
					pb_player.cards[i] = b_player.cards[i]
				end
				pb_player.cards[5] = -1
			else
				pb_player.cards = self.b_player[l_player.guid].cards
			end
		end
		table.insert(notify.pb_player, pb_player)
	end
	if self.b_status > STATUS_BET then
		for _key, b_player in ipairs(notify.pb_player) do
			if math.floor(self.b_status - 1) >= STATUS_SHOW_CARD then
				notify.pb_player[_key].cards = self.b_player[b_player.guid].cards
				notify.pb_player[_key].cards_type = self.b_player[b_player.guid].cards_type and
				self.b_player[b_player.guid].cards_type or BANKER_CARD_TYPE_NONE
			end

			if notify.pb_player[_key].cards_type then
				if notify.pb_player[_key].cards_type > BANKER_CARD_TYPE_NONE and notify.pb_player[_key].cards_type < BANKER_CARD_TYPE_FOUR_KING then
					notify.pb_player[_key].flag = 1
				else
					notify.pb_player[_key].flag = 2
				end
			else
				notify.pb_player[_key].flag = 2
			end
		end
	end

	notify.total_time = self.b_total_time
	if notify.total_time > 0 then
		notify.countdown = math.floor(self.b_timer - get_second_time() + 0.5)
	else
		notify.countdown = 3
		if math.floor(self.b_status) == STATUS_SHOW_CARD then
			notify.total_time = 10
		else
			notify.total_time = 5
		end
	end

	if DEBUG_MODE then
		print("||||||   reconnect info  |||||||||")
		dump(notify)
	end

	if self.b_player[player.guid] then
		self.b_player[player.guid].onTable = true
	end
	notify.pb_Viewer = {}
	for _key, v in pairs(self.players) do
		if v and self.b_player[v.guid] == nil then
			-- 观众
			msg = {
				chair_id = v.chair_id,
				guid = v.guid,
				header_icon = v:get_header_icon(),
				money = v:get_money(),
				ip_area = v.ip_area,
			}
			table.insert(notify.pb_Viewer ,msg)
		end
	end
	notify.bet_options = bet_times_option
	send2client_pb(player, "SC_BankerReconnectInfo", notify)


	log.info("set player[%d] in_game true" ,player.guid)
	player.in_game = true
	return
end

--玩家坐下、初始化
function banker_table:player_sit_down(player, chair_id_)
	print("---------------banker_table player_sit_down  -----------------", chair_id_)
	for i,v in pairs(self.players) do
		if v == player then
			log.info("GameInOutLog,banker_table:player_sit_down return, guid %s,chair_id %s",tostring(player.guid),tostring(chair_id_))

			player:on_stand_up(self.table_id_, v.chair_id, GAME_SERVER_RESULT_SUCCESS)
			return
		end
	end

	player.table_id = self.table_id_
	player.chair_id = chair_id_
	player.room_id = self.room_.id
	self.players[chair_id_] = player

	if self.b_timer <= get_second_time() + 1 and self.b_status == STATUS_WAITING then
		self.b_timer = get_second_time() + 1
	end

	log.info(string.format("GameInOutLog,banker_table:player_sit_down, guid %s, room_id %s, table_id %s, chair_id %s",
	tostring(player.guid),tostring(player.room_id),tostring(player.table_id),tostring(player.chair_id)))
	-- self:playerReady(player)
end


function banker_table:sit_on_chair(player, _chair_id)
	print ("get_sit_down-----------------  banker_table   ----------------")
	self:playerReady(player)
end

function banker_table:in_Banker(player)
	-- body
	if self.b_player[player.guid] then
		return true
	end
	return false
end

function banker_table:playerReady( player )
	-- body
	if player then
		if player.ready == true and self.b_player[player.guid] then
			log.info("player already guid[%d] status[%f]" ,player.guid , self.b_status)
			return
		end
		log.info("playerReady guid[%d] status[%f]" ,player.guid , self.b_status)
		--if self.b_status ~= STATUS_WAITING then
		--	return
		--end
		if self.b_table_busy == 1 and player.banker_enterflag == nil and self.b_status ~= STATUS_WAITING then
			log.info("room[%d] table[%d] player[%d] in table but game in player , wait game end",self.room_.id, self.table_id_ , player.guid)
			player.banker_enterflag = true
			send2client_pb(player, "SC_BankerTableMatching", {})
			self:reconnect(player)
			return
		elseif self.b_table_busy == 1 and player.banker_enterflag == true and self.b_status ~= STATUS_WAITING then
			if player.is_player ~= false then
				log.error("playerReady error player banker_enterflag is true guid[%d]",player.guid)
			end
			--player:forced_exit()
			return
		end
	else
		print("banker_table:playerReady player is nil")
		return
	end
	player.enterTime = nil
	log.info("banker_table:playerReady room[%d] table[%d] chair[%d] player[%d]",self.room_.id, self.table_id_ , player.chair_id, player.guid)
	self.b_player[player.guid] = {
		guid = player.guid,
		chair = player.chair_id,
		cards = {},
		status = PLAYER_STATUS_READY,
		position = POSITION_NORMAL,
		bet = 0,
		ratio = -1,
		show_card = 0,
		cards_type = BANKER_CARD_TYPE_NONE,
		onTable = true,
		bet_times = 1
	}
	player.banker_enterflag = nil
	send2client_pb(player, "SC_BankerTableMatching", {})
	--self.b_timer = get_second_time() + ACTION_INTERVAL_TIME



	self.b_player_count = self.b_player_count + 1
	if self.b_player_count > 1 and self.b_player_count < 6  then
		--self.b_timer = get_second_time() + 5
		--if self.b_player_count > 2 then
			local msg = {
				s_start_time = self.b_timer - get_second_time() - 1
			}
			send2client_pb(player,"SC_StartCountdown", msg)
		--end
	else
		self.b_timer = get_second_time()
	end
	player.ready = true
	log.info("room[%d] table[%d] player_num[%d]",self.room_.id, self.table_id_ , self.b_player_count)


	if player.is_player ~= false  then
		for i, v in ipairs(self.players) do
			if v then
				if type(v) == "table" and v.is_player == false and not self.b_player[v.guid] then
					self:playerReady(v)
				end
			end
		end
	end
end

function banker_table:check_reEnter(player, chair_id)
	print ("check_reEnter -------------------", player.guid)
	local room_limit = self.room_:get_room_limit()
	local l_money = player:get_money()
	player:check_forced_exit(room_limit)
	if  l_money < room_limit then
		local msg = {}
		msg.reason = "金币不足，请您充值后再继续"
		msg.num = room_limit
		send2client_pb(player, "SC_BankerForceToLeave", msg)
		player:forced_exit()

		if DEBUG_MODE then
			print ("-------forced to leave ------------")
			dump(msg)
		end
	else
		for i, v in ipairs(self.players) do
			if v then
				if type(v) == "table" and v.is_player == false and not self.b_player[v.guid] then
					self:playerReady(v)
				end
			end
		end
		self:playerReady(player)
	end
end

--玩家站起离开房间
function banker_table:player_stand_up(player, is_offline)
	log.info(string.format("GameInOutLog,banker_table:player_stand_up, guid %s, table_id %s, chair_id %s, is_offline %s",
	tostring(player.guid),tostring(player.table_id),tostring(player.chair_id),tostring(is_offline)))

	log.info("!!!!!-----------STAND_UPPPP --------------guid[%d] chair[%d] isoffline[%s] status[%s]" ,player.guid, player.chair_id, tostring(is_offline),tostring(self.b_status))
	local notify = {
		table_id = player.table_id,
		chair_id = player.chair_id,
		guid = player.guid,
	}
    if self.b_status == STATUS_WAITING or self.b_status == STATUS_OVER or self.b_player[player.guid] == nil then
		if base_table.player_stand_up(self,player,is_offline) then

--			local notify = {
--					room_id = player.room_id,
--					guid = player.guid,
--			}
--			--self.room_:player_exit_room(player)
--			self.room_:foreach_by_player(function (p)
--				if p and p.guid ~= player.guid then
--					p:on_notify_exit_room(notify)
--				end
--			end)

--			tb:foreach(function (p)
--				p:on_notify_stand_up(notify)
--			end)

			self:robot_leave(player)
			if self.b_player[player.guid]  then
				self.b_player[player.guid] = nil
				self.b_player_count = self.b_player_count - 1
				if self.b_player_count < 1 then
					self:reset()
				end
				if (self.b_status == STATUS_WAITING or self.b_status == STATUS_OVER) and self.b_table_busy == 1 and self.b_player_count < 2 then
					log.info("roomid[%d] ,table_id[%s], chair_id [%s] ,status[%s], player_count[%d]" ,tostring(player.room_id), tostring(player.table_id) , tostring(player.chair_id), tostring(self.b_status) ,self.b_player_count)
					self.b_table_busy = 0
					self:t_broadcast("SC_StartCountdown", nil)
				end
				print("self.b_player[player.guid]   is  true")
			else
				print("self.b_player[player.guid]   is  false")
			end
			return true
		else
			log.info("player [%d] can not standup",player.guid)
			return false
		end
	else
		-- 掉线
		log.info("set player[%d] in_game false" ,player.guid)
		player.is_offline = true
		player.in_game = false
		self.b_player[player.guid].onTable = false
		return false
	end
end
--玩家掉线处理
function  banker_table:player_offline( player )
	log.info("banker_table:player_offline")
	player.isTrusteeship = false
	player.in_game = false

	log.info("player is offline true [%d]",player.guid)
	player.is_offline = true
end
function banker_table:check_cancel_ready(player, is_offline)
	base_table.check_cancel_ready(self,player,is_offline)
	player:setStatus(is_offline)
	if self.b_status > STATUS_WAITING and self.b_status < STATUS_OVER  and self.b_player[player.guid] ~= nil then
		--掉线
		if  is_offline then
			--掉线处理
			self:player_offline(player)
		end
		return false
	end
	--退出
	return true
end


function banker_table:player_leave(player)

	print ("player_leave-----------------  texase   ----------------")
	if self.b_status > STATUS_WAITING and self.b_status < STATUS_OVER then
		log.warning("player [%s] player_leave status[%f] return " , tostring(player.guid), self.b_status)
		return
	end

	local notify = {
			table_id = player.table_id,
			chair_id = player.chair_id,
			guid = player.guid,
			is_offline = false,
	}
	base_table.player_stand_up(self,player,false)
	self:foreach(function (p)
		p:on_notify_stand_up(notify)
	end)
	self.room_:player_exit_room(player)


	self:robot_leave(player)
	if self.b_player[player.guid]  then
		self.b_player[player.guid] = nil
		self.b_player_count = self.b_player_count - 1
		if self.b_player_count < 1 then
			self:reset()
		end
		if (self.b_status == STATUS_WAITING or self.b_status == STATUS_OVER) and self.b_table_busy == 1 and self.b_player_count < 2 then
			log.info("roomid[%d] ,table_id[%s], chair_id [%s] ,status[%s], player_count[%d]" ,tostring(player.room_id), tostring(player.table_id) , tostring(player.chair_id), tostring(self.b_status) ,self.b_player_count)
			self.b_table_busy = 0
		end
		print("self.b_player[player.guid]   is  true")
	else
		print("self.b_player[player.guid]   is  false")
	end
end


function banker_table:t_broadcast(ProtoName, msg)
	for _guid, player in pairs(self.players) do
		if player and not player.is_offline then
			print("t_broadcast",ProtoName)
			send2client_pb(player, ProtoName, msg)
		end
	end
end


-- 判断是否游戏中
function  banker_table:is_play( )
	-- body
	if self.b_status > STATUS_WAITING then
		print("is_play  return true")
		return true
	else
		return false
	end
end

function banker_table:player_quest_last_record(player)
 	-- body
 	local msg = {
		pb_record ={}
	}
	local flag = 0
	for i, v in pairs(self.last_score_record) do
		if v and v.guid == player.guid then
			flag = 1
			break
		end
	end
	if flag == 1 then
		for i, v in pairs(self.last_score_record) do
			if v then
				table.insert(msg.pb_record,v)
			end
		end
		send2client_pb(player,"SC_BankerLastRecord",msg)
	else
		send2client_pb(player,"SC_BankerLastRecord",{})
	end
 end

--黑名单处理
function banker_table:check_black_user(cards)
	--检查概率
	local randon_i = random.boost_integer(1,100)
	print("-------------------check_black_user" , self.black_rate , randon_i )
	if self.black_rate < randon_i then
		print("-----------------------------------------------1")
		return
	end
	--获取最大牌型
	--local max_chair_id = 0
	--local max_cards_type = {}
	--for k,v in pairs(cards) do
	--	local ox_type_,value_list_,color_, extro_num_, sort_cards_ = get_cards_type(v)
	--	local times = get_type_times(ox_type_,extro_num_)
	--	local cur_cards_type = {ox_type = ox_type_,val_list = value_list_, color = color_,cards_times = times }
	--	if max_chair_id == 0 then
	--		max_chair_id = k
	--		max_cards_type = cur_cards_type
	--	elseif compare_cards(cur_cards_type, max_cards_type) then
	--		max_chair_id = k
	--		max_cards_type = cur_cards_type
	--	end
	--end
	--local white = {}
	--for k,v in pairs(self.players) do
	--	if v and self:check_blacklist_player(v.guid) == false then
	--		table.insert(white,v)
	--		if max_chair_id == k then
	--			--最大牌已经在非黑名单玩家手里
	--			return
	--		end
	--	end
	--end
	----不存在白名单玩家
	--if #white == 0 then
	--	return
	--end

	--计算机器人是否为最大牌型
	local max_cards_in_black_player = false
	local min_cards_in_white_player = false

	--运算所有玩家牌类型
	self:run_cards_type()
	local max_chair_id, min_chair_id = self:robot_start_game()
	local player_white_list_temp = {}
	local player_black_list_temp = {}

	for k,v in pairs(self.b_player) do
		if v then
			if self:check_blacklist_player(v.guid) == false then
				table.insert(player_white_list_temp,v)
				if v.chair == min_chair_id then
					min_cards_in_white_player = true
				end
			else
				table.insert(player_black_list_temp,v)
				if v.chair == max_chair_id then
					max_cards_in_black_player = true
				end
			end
		end
	end
	if #player_white_list_temp == 0 or #player_black_list_temp == 0 then
		print("-----------------------------------------------2 ",#player_white_list_temp,#player_black_list_temp)
		return
	end

	log.info("max_cards_in_black_player [%s] min_cards_in_white_player[%s] max_chair_id[%d] min_chair_id[%d]",tostring(max_cards_in_black_player),tostring(min_cards_in_white_player),max_chair_id,min_chair_id)
	print("player_white_list_temp")
	for _,v in pairs(player_white_list_temp) do
		print(v.guid,v.chair)
	end
	print("player_black_list_temp")
	for _,v in pairs(player_black_list_temp) do
		print(v.guid,v.chair)
	end
	print("charge_before")
	dump(cards)
	--换牌
	if max_cards_in_black_player and min_cards_in_white_player then
		-- 最大牌在黑名单玩家手中 最小牌在白名单玩家手中
		local swap_chair_id = min_chair_id
		local max_cards = deepcopy(cards[max_chair_id])
		cards[max_chair_id] = deepcopy(cards[swap_chair_id])
		cards[swap_chair_id] = deepcopy(max_cards)
	elseif max_cards_in_black_player then
		-- 最大牌在黑名单玩家手中
		local swap_chair_id = player_white_list_temp[random.boost_integer(1,#player_white_list_temp)].chair
		local max_cards = deepcopy(cards[max_chair_id])
		cards[max_chair_id] = deepcopy(cards[swap_chair_id])
		cards[swap_chair_id] = deepcopy(max_cards)
	elseif min_cards_in_white_player then
		-- 最小牌在白名单玩家手中
		local swap_chair_id = player_black_list_temp[random.boost_integer(1,#player_black_list_temp)].chair
		local max_cards = deepcopy(cards[min_chair_id])
		cards[min_chair_id] = deepcopy(cards[swap_chair_id])
		cards[swap_chair_id] = deepcopy(max_cards)
	end

	print("charge_after")
	dump(cards)
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then

            return lookup_table[object]
        end  -- if
        local new_table = {}
        lookup_table[object] = new_table


        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--AI
--陪玩机器人初始化
function banker_table:init_robot_random( )
	self.robot_strategy = {--机器人抢桩策略
	good_cards = {
	[0] = 20,
	[1] = 20,
	[2] = 20,
	[3] = 20,
	[4] = 20
	},
	bad_cards = {
	[0] = 20,
	[1] = 20,
	[2] = 20,
	[3] = 20,
	[4] = 20}
	}
	self.robot_bet = {
	good_cards = {
	[1] = 25,
	[2] = 25,
	[3] = 25,
	[4] = 25
	},
	bad_cards = {
	[1] = 25,
	[2] = 25,
	[3] = 25,
	[4] = 25}
	}
end
function banker_table:robot_init()
	self.robot_enter_time = 0 --进入时间
	self.robot_info = {} --机器人
	self.robot_islog = false --是否记录机器人产生的日志
	self.robot_switch = 0 --机器人开关
	self.robot_change_card = 50
	self:init_robot_random()
	self:run_rob_ramdom_value()
	print("--------------------------XXXXXXXXXXXXXXXX",self.robot_strategy.good_cards[0],self.robot_strategy.bad_cards[0])
	log.info(table.concat(self.robot_strategy.good_cards, ','))
	log.info(table.concat(self.robot_strategy.bad_cards, ','))
	log.info(table.concat(self.robot_bet.good_cards, ','))
	log.info(table.concat(self.robot_bet.bad_cards, ','))
end

function banker_table:run_rob_ramdom_value()
	local value = 0
 	for i = 0, 4 do
 		self.robot_strategy.good_cards[i] = value + self.robot_strategy.good_cards[i]
 		value = self.robot_strategy.good_cards[i]
 	end
 	value = 0
 	for i = 0, 4 do
 		self.robot_strategy.bad_cards[i] = value + self.robot_strategy.bad_cards[i]
 		value = self.robot_strategy.bad_cards[i]
 	end
 	value = 0
 	for i = 1, 4 do
 		self.robot_bet.good_cards[i] = value + self.robot_bet.good_cards[i]
 		value = self.robot_bet.good_cards[i]
 	end
 	value = 0
 	for i = 1, 4 do
 		self.robot_bet.bad_cards[i] = value + self.robot_bet.bad_cards[i]
 		value = self.robot_bet.bad_cards[i]
 	end
end

function banker_table:islog(guid)
	if guid > 0 then
		return true
	end
	return self.robot_islog
end

--检查时否可以加入陪玩机器人
function banker_table:check_robot_enter()
	if self.robot_switch ~= 1 then
		return
	end
	local curtime = get_second_time()
	if self.robot_enter_time <= curtime or self:get_robot_num() < 2 then
		--每10秒检查一次
		self.robot_enter_time = get_second_time() + random.boost_integer(2,5) + 5
		if self:get_robot_num() < 3 and self:get_player_count() < 5 then
			--添加一个机器人
			local ap =  self:get_robot()
			if ap then
				for i,p in pairs(self.players) do
					if p == nil or p == false then
						ap:think_on_sit_down(self.room_.id, self.table_id_, i)
						--self:player_sit_down(ap,i)
						self:playerReady(ap)
						break
					end
				end
			end
		end
	end
end

--检查陪玩机器人离开
function banker_table:check_robot_leave()

	local leave ={}
	if self.robot_switch == 1 then
		for _,v in pairs(self.robot_info) do
			if v.is_use then
				v.android.cur = v.android.cur + 1
				if v.android.cur >= v.android.round or self.room_:get_room_limit() > v.android:get_money() then
					table.insert(leave,v.android)
				end
			end
		end
	else
		for _,v in pairs(self.robot_info) do
			if v.is_use then
				v.android.cur = v.android.cur + 1
				table.insert(leave,v.android)
			end
		end
	end
	for _,v in pairs(leave) do
		if v.table_id and v.chair_id then
			local notify = {
					table_id = v.table_id,
					chair_id = v.chair_id,
					guid = v.guid,
				}
			self:player_stand_up(v, false)
			self:foreach(function (p)
				p:on_notify_stand_up(notify)
			end)

			self.room_:player_exit_room(v)
			self.robot_enter_time = get_second_time() + 10
		end
	end
end

--获取陪玩机器人数量
function banker_table:get_robot_num()
	local num = 0
	for i, p in pairs(self.players) do
		if p and p.is_player == false then
			num = num + 1
		end
	end
	return num
end

--创建一个陪玩机器人
function banker_table:get_robot()
	if #self.robot_info < 3 then
		local guid = 0 - #self.robot_info - 1
		local android_player = banker_android:new()
		local account  =  "android_"..tostring(guid)
		local nickname =  "android_"..tostring(guid)
		android_player:init(self.room_.id, guid, account, nickname)
		android_player:set_table(self)
		local info = {}
		info.is_use = false
		info.android = android_player
		table.insert(self.robot_info,info)
		self:reset_robot(android_player)
	end
	for _,v in pairs(self.robot_info) do
		if v.is_use == false then
			self:reset_robot(v.android)
			v.is_use = true
			return v.android
		end
	end
	return nil
end

--重置机器人
function banker_table:reset_robot(android)
	if android.is_player then
		return
	end
	android.round = random.boost_integer(3,6)
	android.cur = 0
	android.money = self.room_:get_room_limit() * random.boost_integer(2,20)
	--if def_second_game_type == 1 then
	--	android.money = random.boost_integer(120,500) * 100 + random.boost_integer(0,100)
	--elseif def_second_game_type == 2 then
	--	android.money = random.boost_integer(120,500) * 100 + random.boost_integer(0,100)
	--elseif def_second_game_type == 3 then
	--	android.money = random.boost_integer(400,800) * 100 + random.boost_integer(0,100)
	--elseif def_second_game_type == 4 then
	--	android.money = random.boost_integer(1300,2900) * 100 + random.boost_integer(0,100)
	--elseif def_second_game_type == 5 then
	--	android.money = random.boost_integer(2300,3800) * 100 + random.boost_integer(0,100)
	--else
	--	android.money = self.room_:get_room_limit() * random.boost_integer(100,200)
	--end
	android:reset_show()
end

--释放机器人
function banker_table:robot_leave(android)
	if android.is_player then
		return
	end
	for _,v in pairs(self.robot_info) do
		if v.android.guid == android.guid then
			v.is_use = false
		end
	end
end

--计算机器人牌型大小
function banker_table:robot_start_game()
	local max_chair_id = 0
	local mix_chair_id = 0
	local temp = nil
	local temp_bplayer = nil
	for _guid, b_player in pairs(self.b_player) do
		if b_player.cards then
			if temp == nil then
				temp = self.b_ret[_guid]
				temp_bplayer = b_player
			else
				local win = compare_cards(self.b_ret[_guid], temp)
				if win == true then
					temp = self.b_ret[_guid]
					temp_bplayer = b_player
				end
			end
		end
	end
	if temp_bplayer ~= nil then
		max_chair_id = temp_bplayer.chair
	else
		log.error("robot_start_game error no max_bplayer")
	end

	for _,v in pairs(self.robot_info) do
		v.android:set_maxcards(false)
		if v.is_use and v.android.chair_id == max_chair_id then
			v.android:set_maxcards(true)
		end
	end

	--	计算最小牌型
	temp = nil
	temp_bplayer = nil
	for _guid, b_player in pairs(self.b_player) do
		if b_player.cards then
			if temp == nil then
				temp = self.b_ret[_guid]
				temp_bplayer = b_player
			else
				local win = compare_cards(self.b_ret[_guid], temp)
				if win == false then
					temp = self.b_ret[_guid]
					temp_bplayer = b_player
				end
			end
		end
	end
	if temp_bplayer ~= nil then
		mix_chair_id = temp_bplayer.chair
	else
		log.error("robot_start_game error no max_bplayer")
	end

	for _,v in pairs(self.robot_info) do
		v.android:set_mixcards(false)
		if v.is_use and v.android.chair_id == mix_chair_id then
			v.android:set_mixcards(true)
		end
	end

	self.robot_islog = false
	for _,v in pairs(self.players) do
		if v and v.is_player then
			self.robot_islog = true
			break
		end
	end
	return max_chair_id, mix_chair_id
end

-- 机器人抢桩
function banker_table:start_contend_timer(time,player)
	local function contend_func()
		local r = random.boost_integer(1,100)
		local ratio = 0
		if player:is_max() then
			--抢桩
			if r < self.robot_strategy.good_cards[0] then
				ratio = -1
			elseif r < self.robot_strategy.good_cards[1] then
				ratio = 1
			elseif r < self.robot_strategy.good_cards[2] then
				ratio = 2
			elseif r < self.robot_strategy.good_cards[3] then
				ratio = 3
			else
				ratio = 4
			end
		else
			--抢桩
			if r < self.robot_strategy.bad_cards[0] then
				ratio = -1
			elseif r < self.robot_strategy.bad_cards[1] then
				ratio = 1
			elseif r < self.robot_strategy.bad_cards[2] then
				ratio = 2
			elseif r < self.robot_strategy.bad_cards[3] then
				ratio = 3
			else
				ratio = 4
			end
		end
		self:banker_contend(player, ratio)
	end
	add_timer(time,contend_func)
end

-- 闲家下注
function banker_table:start_begin_to_bet_timer(time,player)
	--闲家下注
	if self.b_banker.chair == player.chair_id then
		return
	end
	local function begin_to_bet_func()
		local r = random.boost_integer(1,100)
		local bet_times = 1
		if player:is_max() then
			--下注
			if r < self.robot_bet.good_cards[1] then
				bet_times = bet_times_option[4]
			elseif r < self.robot_bet.good_cards[2] then
				bet_times = bet_times_option[3]
			elseif r < self.robot_bet.good_cards[3] then
				bet_times = bet_times_option[2]
			else
				bet_times = bet_times_option[1]
			end
		else
			--下注
			if r < self.robot_bet.bad_cards[1] then
				bet_times = bet_times_option[4]
			elseif r < self.robot_bet.bad_cards[2] then
				bet_times = bet_times_option[3]
			elseif r < self.robot_bet.bad_cards[3] then
				bet_times = bet_times_option[2]
			else
				bet_times = bet_times_option[1]
			end
		end
		local msg = {bet_money = 0, bet_times = bet_times}
		self:banker_bet(player, msg)
	end
	add_timer(time,begin_to_bet_func)
end

-- 猜牌
function banker_table:start_guess_cards_timer(time,player)
	local function begin_tguess_cards_func()
		self:banker_guess_cards(player)
	end
	add_timer(time,begin_tguess_cards_func)
end

return banker_table
local base_table = require "game.lobby.base_table"
local def 		= require "game.changpai_zigong.base.define"
local mj_util 	= require "game.changpai_zigong.base.changpai_util"
local log = require "log"
local json = require "json"
local changpai_tile_dealer = require "changpai_tile_dealer"
local base_private_table = require "game.lobby.base_private_table"
local enum = require "pb_enums"
local club_utils = require "game.club.club_utils"
local timer = require "timer"

require "functions"

local table = table
local string = string
local tinsert = table.insert
local tremove = table.remove
local tconcat = table.concat
local strfmt = string.format

local FSM_S  = def.FSM_state

local ACTION = def.ACTION
local TIME_TYPE = def.TIME_TYPE
local ACTION_PRIORITY = {
    [ACTION.PASS] = 6,
    [ACTION.PENG] = 4,
    [ACTION.TOU] = 3,
    [ACTION.BA_GANG] = 2,
    [ACTION.TING] = 2,
    [ACTION.HU] = 1,
    [ACTION.ZI_MO] = 1,
    [ACTION.CHI] = 5,
}
local USER_PRIORITY = {
    [1]={[1] = 1,[2] = 2,[3] = 3,[4] = 4 },
    [2]={[2] = 1,[3] = 2,[4] = 3,[1] = 4,},
    [3]={[3] = 1,[4] = 2,[1] = 3,[2] = 4,},
    [4]={[4] = 1,[1] = 2,[2] = 3,[3] = 4 },
}


local SECTION_TYPE = def.SECTION_TYPE
local TILE_AREA = def.TILE_AREA
local HU_TYPE_INFO = def.HU_TYPE_INFO
local HU_TYPE = def.CP_HU_TYPE
local BTEST = false
local all_tiles_data ={
	[1]={value=2,hong=2,hei=0,index=1},
	[2]={value=3,hong=1,hei=2,index=2},
	[3]={value=4,hong=1,hei=3,index=3},
	[4]={value=4,hong=0,hei=4,index=4},
	[5]={value=5,hong=5,hei=0,index=5},
	[6]={value=5,hong=0,hei=5,index=6},
	[7]={value=6,hong=0,hei=6,index=7},
	[8]={value=6,hong=1,hei=5,index=8},
	[9]={value=6,hong=4,hei=2,index=9},
	[10]={value=7,hong=0,hei=7,index=10},
	[11]={value=7,hong=1,hei=6,index=11},
	[12]={value=7,hong=4,hei=3,index=12},
	[13]={value=8,hong=0,hei=8,index=13},
	[14]={value=8,hong=0,hei=8,index=14},
	[15]={value=8,hong=8,hei=0,index=15},
	[16]={value=9,hong=0,hei=9,index=16},
	[17]={value=9,hong=4,hei=5,index=17},
	[18]={value=10,hong=0,hei=10,index=18},
	[19]={value=10,hong=4,hei=6,index=19},
	[20]={value=11,hong=0,hei=11,index=20},
	[21]={value=12,hong=6,hei=6,index=21}
}
local all_tiles = {
    [1] = {
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
    }
}

local play_opt_conf = {
    si_ren_liang_fang = {
        start_count = 4,
        tiles = {
            all = {
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
            },
        }
    },
    san_ren_liang_fang = {
        start_count = 3,
        tiles = {
            count = 13,
            all = {
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
            },
        }
    },
    er_ren_san_fang = {
        start_count = 2,
        tiles = {
            count = 13,
            all = {
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
            },
        }
    },
    er_ren_liang_fang = {
        start_count = 2,
        tiles = {
            count = 13,
            all = {
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
            },
        }
    },
    er_ren_yi_fang = {
        start_count = 2,
        tiles = {},
    },
}

local function get_play_conf(play_opt,tiles_opt)
    local play_conf = play_opt_conf[play_opt]
    if not play_conf then return end

    local start_count = play_conf.start_count
    local tiles_conf = play_conf.tiles

    local function get_all_tiles(opt)
        if tiles_conf.all then
            return tiles_conf.all
        end

        if not opt or opt > 2 or opt < 0 then
            log.error("get_play_conf got invalid tiles opt.%s",opt)
            return all_tiles[start_count]
        end

        local tiles = {}
        for i = 1,9 do
            tinsert(tiles,opt * 10 + i)
            tinsert(tiles,opt * 10 + i)
            tinsert(tiles,opt * 10 + i)
            tinsert(tiles,opt * 10 + i)
        end

        return tiles
    end

    local function get_game_tile_count(opt)
        if tiles_conf.count then
            return tiles_conf.count
        end

        return opt
    end

    return start_count,get_all_tiles(tiles_opt.all),get_game_tile_count(tiles_opt.count)
end


local changpai_table = base_table:new()

-- 初始化
function changpai_table:init(room, table_id, chair_count)
	base_table.init(self, room, table_id, chair_count)
    self.cur_state_FSM = nil
    self.start_count = self.chair_count
end

function changpai_table:on_private_inited()
    self.cur_round = nil
    self.zhuang = nil
    self.zhuang_pai = nil
    self.qie_pai = nil
    self.game_tile_count = 15
    local room_private_conf = self:room_private_conf()
    if not room_private_conf then return end

    if not room_private_conf.play then return end

    local play_opt = room_private_conf.play.option
    if not play_opt then return end

    local rule_play = self.rule.play

    local start_count,tiles,game_tile_count = get_play_conf(play_opt,{
        count = rule_play.tile_count,
        all = rule_play.tile_men,
    })
    game_tile_count=15
    self.start_count = start_count--开始人数
    self.tiles = all_tiles[4]     --所有的牌，没啥变化，基本固定死了
    self.game_tile_count = 15     --开局的牌数，也是没啥变化，基本也是固定死
    self.game_tile_count = game_tile_count
    self.cur_state_FSM = nil

    log.dump(tiles)
    log.dump(game_tile_count)
end

function changpai_table:on_private_dismissed()
    log.info("changpai_table:on_private_dismissed")
    self.cur_round = nil
    self.zhuang = nil
    
    self.zhuang_pai = nil
    self.qie_pai = nil
    self.tiles = nil
    self.cur_state_FSM = nil
    for _,p in pairs(self.players) do
        p.total_money = nil
    end
    self:cancel_all_auto_action_timer()
    self:cancel_clock_timer()

    base_table.on_private_dismissed(self)
end

function changpai_table:check_start()
    if self:is_play() then
        log.error("changpai_table:check_start is gaming %s",self:id())
        return
    end

    if table.nums(self.ready_list) == self.start_count then
        self:start(self.start_count)
    end
end

function changpai_table:on_started(player_count)
    self.start_count = player_count
    base_table.on_started(self,player_count)
    if BTEST then
        self.zhuang = 1
    else
        self.zhuang = not self.zhuang and self:first_zhuang() or self.zhuang    
    end
    for _,v in pairs(self.players) do
        v.hu                    = nil
        v.deposit               = false
        v.last_action           = nil
        v.mo_pai_count          = 0
        v.chu_pai_count         = 0
        v.pai                   = {
            shou_pai = {},
            ming_pai = {},
            desk_tiles = {},
            bao_pai = {},
            
        }
        v.zhuan_shou_pai = nil
        v.jiao                  = nil
        v.is_bao_pai = false  --玩家的上家是否对他形成包牌

        v.mo_pai = nil
        v.chu_pai = nil
        v.que = nil
        v.first_multi_pao = nil
        v.gzh = nil
        v.gsp = nil
        v.gsc = nil
        v.statistics = v.statistics or {}
        v.last_penghu = nil
    end

    
	self.chu_pai_player_index      = self.zhuang --出牌人的索引
    self.last_chu_pai              = -1 --上次的出牌
    self.mo_pai_count = nil
    self:update_state(FSM_S.PER_BEGIN)
    self.game_log = {
        start_game_time = os.time(),
        zhuang = self.zhuang,
        mj_min_scale = self.mj_min_scale,
        players = table.map(self.players,function(_,chair) return chair,{} end),
        action_table = {},
        rule = self.private_id and self.rule or nil,
        club = (self.private_id and self.conf.club) and club_utils.root(self.conf.club).id,
        table_id = self.private_id or nil,
    }

    self.tiles = self.tiles or all_tiles[1]
    self.dealer = nil
    self.dealer = changpai_tile_dealer:new(self.tiles)
    self:cancel_clock_timer()
    self:cancel_all_auto_action_timer()
    self:pre_begin()--这里是包括定庄，洗牌，发牌，庄家摸第16张牌，给在位置的所有玩家发送牌数据
    ---self:action_after_fapai()
    log.dump("开始游戏了")
    self:begin_main_timer(TIME_TYPE.MAIN_XI_PAI,TIME_TYPE.MAIN_XI_PAI,function ()
  
        self:broadcast2client("Changpai_Toupaistate",{status = FSM_S.WAIT_ACTION_AFTER_FIRSTFIRST_TOU_PAI,})
        self:action_after_fapai()
    end,"action_after_fapai")--偷牌阶段第一个先偷，假如有时间等待时间，不然下家偷
end
function changpai_table:action_after_fapai()
    self:update_state(FSM_S.WAIT_ACTION_AFTER_FIRSTFIRST_TOU_PAI)
    local player = self:chu_pai_player()

    local actions = self:get_actions_first_turn(player)
    log.dump(actions)
    if table.nums(actions) > 0 then
        self:action_after_tou_pai({
            [self.chu_pai_player_index] = {
                actions = actions,
                chair_id = self.chu_pai_player_index,
                session_id = self:session(),
            },
        })
    else
        self:next_player_index() --没有actions 跳到下家
        if(self.chu_pai_player_index==self.zhuang) then
            self:action_after_first_tou()
        else
            self:action_after_fapai()
        end
    end
end
function changpai_table:on_action_after_tianhu(player,msg,auto)
    local action = self:check_action_before_do(self.waiting_actions,player,msg)
    if not action then 
        log.warning("on_action_after_mo_pai invalid action guid:%s,action:%s",player.guid,msg.action)
        return 
    end

    self:cancel_clock_timer()
    self:cancel_all_auto_action_timer()

    local do_action = msg.action
    local chair_id = player.chair_id
    local tile = msg.value_tile

    if chair_id ~= self.chu_pai_player_index then
        log.error("do action:%s but chair_id:%s is not current chair_id:%s after mo_pai",
            do_action,chair_id,self.chu_pai_player_index)
        return
    end

    log.dump(self.waiting_actions,tostring(player.guid))
    local player = self:chu_pai_player()
    if not player then
        log.error("do action %s,but wrong player in chair %s",do_action,player.chair_id)
        return
    end

    local waiting = self.waiting_actions[player.chair_id]

    local session_id = waiting.session_id

    local player_actions = self.waiting_actions[player.chair_id].actions
    if not player_actions[do_action] and do_action ~= ACTION.PASS and do_action ~= ACTION.CHU_PAI then
        log.error("do action %s,but action is illigle,%s",do_action)
        return
    end

    self.waiting_actions = {}
    if do_action == ACTION.ZI_MO then
        -- 天胡
        local is_zi_mo = true
        player.hu = {
            time = timer.nanotime(),
            tile = tile,
            types = self:hu(player,nil,player.mo_pai),
            zi_mo = is_zi_mo,
        }

        player.statistics.zi_mo = (player.statistics.zi_mo or 0) + 1

        self:log_game_action(player,do_action,tile,auto)
        self:broadcast_player_hu(player,do_action)
        self:do_balance()
    end

    if do_action == ACTION.PASS then
        send2client(player,"SC_Changpai_Do_Action",{
            action = do_action,
            chair_id = player.chair_id,
            session_id = msg.session_id,
        })
        self:broadcast_discard_turn()
        self:chu_pai()
        return
    end

    self:done_last_action(player,{action = do_action,tile = tile,})
end
function changpai_table:action_after_first_tou()--偷牌结束要么天胡，要么出牌
    local player = self:chu_pai_player()

    local mo_pai = self:choice_first_turn_mo_pai(player)
    log.dump(mo_pai)

    log.info("---------fake mo pai,guid:%s,pai:  %s ------",player.guid,mo_pai)
    self:broadcast2client("SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})

    local actions = self:get_actions(player,mo_pai,nil,nil,nil)
    log.dump(actions)
    if table.nums(actions) > 0 and actions[ACTION.ZI_MO] then
        self:first_action_tianhu({
            [self.chu_pai_player_index] = {
                actions = actions[ACTION.ZI_MO], --这个时候只发天胡给玩家
                chair_id = self.chu_pai_player_index,
                session_id = self:session(),
            },
        })
    else
        --这里可能要加一条信息告诉玩家出牌动作
        self:broadcast_discard_turn()
        self:chu_pai()
    end

end
function changpai_table:fast_start_vote_req(player)
    local player_count = table.sum(self.players,function(p) return 1 end)
    if player_count < 2 then
        send2client(player,"SC_VoteTableReq",{
            result = enum.ERROR_OPERATION_INVALID
        })
        return
    end

    self:lockcall(function() self:fast_start_vote(player) end)
end

function changpai_table:fast_start_vote_commit(p,msg)
    self:lockcall(function()
        local agree = msg.agree
        agree = agree and true or false
        if not self.vote_result[p.chair_id] then
            self.vote_result[p.chair_id] = agree
        end

        self:broadcast2client("SC_VoteTableCommit",{
            result = enum.ERROR_NONE,
            chair_id = p.chair_id,
            guid = p.guid,
            agree = agree,
        })

        if agree then
            if not table.And(self.players,function(_,chair) return self.vote_result[chair] ~= nil end) then
                return
            end
        end

        local all_agree = table.And(self.vote_result,function(a) return a end)
        self:broadcast2client("SC_VoteTable",{success = all_agree})
        if not all_agree then
            self:update_state(nil)
            self.co = nil
            return true
        end

        self:start(table.nums(self.players))
    end)
end

function changpai_table:on_reconnect_when_fast_start_vote(player)
    local status = {}
    for chair,r in pairs(self.vote_result) do
        local pi = self.players[chair]
        tinsert(status,{
            chair_id = pi.chair_id,
            guid = pi.guid,
            agree = r,
        })
    end

    send2client(player,"SC_VoteTableRequestInfo",{
        vote_type = "FAST_START",
        request_guid = player.guid,
        request_chair_id = player.chair_id,
        -- timeout= math.ceil(timer and timer.remainder or timeout),
        status = status
    })
end

function changpai_table:fast_start_vote(player)
    self:update_state(FSM_S.FAST_START_VOTE)
    
    local timeout = 60
    self:broadcast2client("SC_VoteTableReq",{
        vote_type = "FAST_START",
        request_guid = player.guid,
        request_chair_id = player.chair_id,
        timeout = timeout,
    })

    self.vote_result = {}

    self.vote_result[player.chair_id] = true
    self:broadcast2client("SC_VoteTableCommit",{
        result = enum.ERROR_NONE,
        chair_id = player.chair_id,
        guid = player.guid,
        agree = true,
    })

    self:begin_clock_timer(timeout,function()
        self:foreach(function(p)
            if self.vote_result[p.chair_id] == nil then
                self:fast_start_vote_commit(p,{agree = false})
            end
        end)
    end)
end

function changpai_table:set_trusteeship(player,trustee)
    if not self.rule.trustee or table.nums(self.rule.trustee) == 0 then
        return 
    end

    base_table.set_trusteeship(self,player,trustee)
    if not trustee then
        self:cancel_auto_action_timer(player)
    end

    if self.game_log then
        table.insert(self.game_log.action_table,{chair = player.chair_id,act = "Trustee",trustee = trustee,time = timer.nanotime()})
    end
end

function changpai_table:on_offline(player)
	base_table.on_offline(self,player)
    if self.game_log then
	    table.insert(self.game_log.action_table,{chair = player.chair_id,act = "Offline",time = timer.nanotime()})
    end
end

function changpai_table:on_reconnect(player)
	base_table.on_reconnect(self,player)
	if self.game_log then
		table.insert(self.game_log.action_table,{chair = player.chair_id,act = "Reconnect",time = timer.nanotime()})
	end
end

function changpai_table:session()
    self.session_id = (self.session_id or 0) + 1
    return self.session_id
end

function changpai_table:xi_pai()
    self:update_state(FSM_S.XI_PAI)
    self:prepare_tiles()
    self:foreach(function(v)
        self:send_data_to_enter_player(v)
        self.game_log.players[v.chair_id].start_pai = self:tile_count_2_tiles(v.pai.shou_pai)
    end)
    self:broadcast2client("SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
end

function changpai_table:on_reconnect_when_action_qiang_gang_hu(p)
    send2client(p,"SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})

    self:send_ting_tips(p)

    if self.main_timer then
        self:begin_clock(self.main_timer.remainder,p)
    end
    
    for chair,actions in pairs(self.qiang_gang_actions or {}) do
        self:send_action_waiting(actions)
    end
end

function changpai_table:on_action_qiang_gang_hu(player,msg,auto)
    if self.cur_state_FSM ~= FSM_S.WAIT_QIANG_GANG_HU then
        log.error("changpai_table:on_action_qiang_gang_hu wrong state %s",self.cur_state_FSM)
        return
    end
    
    local done_action = self:check_action_before_do(self.qiang_gang_actions or {},player,msg)
    if not done_action then 
        log.error("on_action_qiang_gang_hu,no wait qiang gang action,%s",player.guid)
        return
    end

    local tile = msg.value_tile

    self:cancel_auto_action_timer(player)

    done_action.done = { action = msg.action,auto = auto }
    local all_done = table.And(self.qiang_gang_actions or {},function(action) return action.done ~= nil end) 
    if not all_done then
        return
    end

    local target_act = done_action.target_action
    local qiang_tile = done_action.tile
    local chu_pai_player = self:chu_pai_player()
    --点击pass 就设置过手胡
    local function check_all_pass(actions)
        for _,act in pairs(actions) do
            if act.done.action == ACTION.PASS then
                local p = self.players[act.chair_id]
                if self.rule.play.guo_zhuang_hu then
                    local hu_action = act.actions[ACTION.QIANG_GANG_HU]
                    if hu_action then
                        self:set_gzh_on_pass(p,act.tile)
                    end
                end
            end
        end
    end


    local all_pass = table.And(self.qiang_gang_actions or {},function(action) return action.done.action == ACTION.PASS end)
    if all_pass then
        check_all_pass(self.qiang_gang_actions)
        self.qiang_gang_actions = nil
        self:adjust_shou_pai(chu_pai_player,target_act,qiang_tile)
        chu_pai_player.statistics.ming_gang = (chu_pai_player.statistics.ming_gang or 0) + 1
        chu_pai_player.gzh = nil
        self:log_game_action(chu_pai_player,target_act,qiang_tile)
        self:done_last_action(chu_pai_player,{action = target_act,tile = qiang_tile})
        self:mo_pai()
        return
    end

    self:log_failed_game_action(chu_pai_player,target_act,tile)
    local qiang_hu_count = table.sum(self.qiang_gang_actions or {},function(waiting)
        return (waiting.done and waiting.done.action & (ACTION.QIANG_GANG_HU | ACTION.HU)) and 1 or 0
    end)
    local hu_count_before = table.sum(self.players,function(p) return p.hu and 1 or 0 end)
    chu_pai_player.first_multi_pao = (hu_count_before == 0 and qiang_hu_count > 1) or nil
    local qianggangdecr = true 
    local function do_qiang_gang_hu(p,action)
        local act = action.done.action
        local done_action_tile = action.tile
        p.hu = {
            time = timer.nanotime(),
            tile = done_action_tile,
            types = self:hu(p,done_action_tile,nil,true),
            zi_mo = false,
            whoee = self.chu_pai_player_index,
            qiang_gang = true,
        }

        self:log_game_action(p,act,done_action_tile,action.done.auto)
        self:broadcast_player_hu(p,act,action.target)
        p.statistics.hu = (p.statistics.hu or 0) + 1
        chu_pai_player.statistics.dian_pao = (chu_pai_player.statistics.dian_pao or 0) + 1
        if  qianggangdecr then 
            table.decr(chu_pai_player.pai.shou_pai,done_action_tile)
            qianggangdecr = false 
        end 
        self:done_last_action(p,{action = act,tile = done_action_tile})
    end
    check_all_pass(self.qiang_gang_actions)
    table.foreach(self.qiang_gang_actions or {},function(action,chair)
        local done_act = action.done.action
        if (done_act & (ACTION.QIANG_GANG_HU | ACTION.HU)) > 0 then
            local p = self.players[chair]
            do_qiang_gang_hu(p,action)
        end
    end)

    local hu_count = table.sum(self.players,function(p) return p.hu and 1 or 0 end)
    if hu_count>0 then
        self:do_balance()
        return
    end

    --local _,last_hu_chair = table.max(self.qiang_gang_actions or {},function(_,c) return c end)
    --local last_hu_player = self.players[last_hu_chair]
    --self:next_player_index(last_hu_player)
    --self:mo_pai()
end

function changpai_table:qiang_gang_hu(player,actions,tile)
    self:update_state(FSM_S.WAIT_QIANG_GANG_HU)
    self.qiang_gang_actions = actions
    for chair,action in pairs(actions) do
        self:send_action_waiting(action)
    end

    table.insert(self.game_log.action_table,{
        act = "WaitActions",
        data = table.series(actions,function(v)
            return {
                chair_id = v.chair_id,
                session_id = v.session_id,
                actions = self:series_action_map(v.actions),
            }
        end),
        time = timer.nanotime()
    })

    local trustee_type,trustee_seconds = self:get_trustee_conf()
    if trustee_type then
        local function auto_action(p,action)
            self:lockcall(function()
                self:on_action_qiang_gang_hu(p,{
                    action = ACTION.QIANG_GANG_HU,
                    value_tile = tile,
                    session_id = action.session_id,
                })
            end)
        end

        log.dump(self.qiang_gang_actions)
        self:begin_clock_timer(trustee_seconds,function()
            table.foreach(self.qiang_gang_actions,function(action,_)
                if action.done then return end

                local p = self.players[action.chair_id]
                self:set_trusteeship(p,true)
                auto_action(p,action)
            end)
        end)

        table.foreach(self.qiang_gang_actions,function(action,_) 
            local p = self.players[action.chair_id]
            if not p.trustee then return end

            self:begin_auto_action_timer(p,math.random(1,2),function() 
                auto_action(p,action)
            end)
        end)
    end
end


function changpai_table:begin_auto_action_timer(p_or_chair,timeout,fn)
    local chair_id = type(p_or_chair) == "table" and p_or_chair.chair_id or p_or_chair
    if self.action_timers[chair_id] then
        log.warning("changpai_table:begin_auto_action_timer timer not nil")
    end
    self.action_timers[chair_id] = self:calllater(timeout,fn)
end

function changpai_table:cancel_auto_action_timer(p_or_chair)
    self.action_timers = self.action_timers or {} 
    local chair_id = type(p_or_chair) == "table" and p_or_chair.chair_id or p_or_chair
    if self.action_timers[chair_id] then
        self.action_timers[chair_id]:kill()
        self.action_timers[chair_id] = nil
    end
end

function changpai_table:cancel_all_auto_action_timer()
    for _,timer in pairs(self.action_timers or {}) do
        timer:kill()
    end

    self.action_timers = {}
end

function changpai_table:begin_main_timer(timeout,totaltime,fn,...)
    if self.main_timer then 
        log.warning("changpai_table:begin_clock_timer timer not nil")
        self.main_timer:kill()
    end

    self.main_timer = self:new_timer(timeout,fn,...)
   --self:begin_clock(timeout,nil,totaltime)

    log.info("changpai_table:begin_clock_timer table_id:%s,timer:%s,timout:%s",self.table_id_,self.main_timer.id,timeout)
end
function changpai_table:cancel_main_timer()
    log.info("changpai_table:cancel_clock_timer table_id:%s,timer:%s",self.table_id_,self.main_timer and self.main_timer.id or nil)
    if self.main_timer then
        self.main_timer:kill()
        self.main_timer = nil
    end
end
function changpai_table:begin_clock_timer(timeout,fn)
    if self.clock_timer then 
        log.warning("changpai_table:begin_clock_timer timer not nil")
        self.clock_timer:kill()
    end

    self.clock_timer = self:new_timer(timeout,fn)
    self:begin_clock(timeout)

    log.info("changpai_table:begin_clock_timer table_id:%s,timer:%s,timout:%s",self.table_id_,self.clock_timer.id,timeout)
end

function changpai_table:cancel_clock_timer()
    log.info("changpai_table:cancel_clock_timer table_id:%s,timer:%s",self.table_id_,self.clock_timer and self.clock_timer.id or nil)
    if self.clock_timer then
        self.clock_timer:kill()
        self.clock_timer = nil
    end
end

function changpai_table:on_action_after_mo_pai(player,msg,auto)
    local action = self:check_action_before_do(self.waiting_actions,player,msg)
    if not action then 
        log.warning("on_action_after_mo_pai invalid action guid:%s,action:%s",player.guid,msg.action)
        return 
    end

    self:cancel_clock_timer()
    self:cancel_all_auto_action_timer()

    local do_action = msg.action
    local chair_id = player.chair_id
    local tile = msg.value_tile

    if chair_id ~= self.chu_pai_player_index then
        log.error("do action:%s but chair_id:%s is not current chair_id:%s after mo_pai",
            do_action,chair_id,self.chu_pai_player_index)
        return
    end

    log.dump(self.waiting_actions,tostring(player.guid))
    local player = self:chu_pai_player()
    if not player then
        log.error("do action %s,but wrong player in chair %s",do_action,player.chair_id)
        return
    end

    local waiting = self.waiting_actions[player.chair_id]

    local session_id = waiting.session_id

    local player_actions = self.waiting_actions[player.chair_id].actions
    if not player_actions[do_action] and do_action ~= ACTION.PASS and do_action ~= ACTION.CHU_PAI then
        log.error("do action %s,but action is illigle,%s",do_action)
        return
    end

    self.waiting_actions = {}

    if (do_action & ACTION.BA_GANG) > 0 then
        local qiang_gang_hu = {}
        self:foreach_except(player,function(p)
            if p.hu then return end

            local actions = self:get_actions(p,nil,tile,true,nil,true)
            if not actions[ACTION.HU] then return end

            qiang_gang_hu[p.chair_id] = {
                chair_id = p.chair_id,
                target = chair_id,
                target_action = do_action,
                tile = tile,
                actions = {
                    [ACTION.QIANG_GANG_HU] = actions[ACTION.HU]
                },
                session_id = self:session(),
            }
        end)
        log.dump(qiang_gang_hu)
        if table.nums(qiang_gang_hu) > 0 then
            send2client(player,"SC_Changpai_Do_Action_Commit",{
                action = do_action,
                chair_id = player.chair_id,
                session_id = msg.session_id,
            })
            
            self:qiang_gang_hu(player,qiang_gang_hu,tile)
            return
        end

        self:log_game_action(player,do_action,tile,auto)
        self:adjust_shou_pai(player,do_action,tile,session_id)
        self:clean_gzh(player)
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:jump_to_player_index(player)
        player.statistics.ming_gang = (player.statistics.ming_gang or 0) + 1
        player.gzh = nil
        self:mo_pai()
        
    end
    if do_action == ACTION.TOU then
        self:clean_gzh(player)
        self:adjust_shou_pai(player,do_action,tile,session_id)
        self:log_game_action(player,do_action,tile,auto)
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:mo_pai()
        
    end


    if do_action == ACTION.HU or do_action == ACTION.ZI_MO then
        local is_zi_mo = true
        player.hu = {
            time = timer.nanotime(),
            tile = tile,
            types = self:hu(player,nil,player.mo_pai),
            zi_mo = is_zi_mo,  
        }

        player.statistics.zi_mo = (player.statistics.zi_mo or 0) + 1

        self:log_game_action(player,do_action,tile,auto)
        self:broadcast_player_hu(player,do_action)
        local hu_count  = table.sum(self.players,function(p) return p.hu and 1 or 0 end)
        if  hu_count  > 0 then
            self:do_balance()
        end
    end

    if do_action == ACTION.PASS then
        send2client(player,"SC_Changpai_Do_Action",{
            action = do_action,
            chair_id = player.chair_id,
            session_id = msg.session_id,
        })
        self:broadcast_discard_turn()
        self:chu_pai()
        return
    end

    self:done_last_action(player,{action = do_action,tile = tile,})
end
function changpai_table:on_reconnect_when_action_after_fan_pai(p)
    send2client(p,"SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})

    local action = self.waiting_actions[p.chair_id]
    if action and not action.done then
        self:send_action_waiting(action)
    end

end
function changpai_table:on_reconnect_when_action_after_mo_pai(p)
    send2client(p,"SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
    local action = self.waiting_actions[p.chair_id]
    if action and not action.done then
        self:send_action_waiting(action)
    end

end
--偷牌摆牌进牌后，产生的事件，以及通知玩家事件等待响应，已经托管玩家的自动响应机制
function changpai_table:action_after_tou_pai(waiting_actions)
    self:update_state(FSM_S.WAIT_ACTION_AFTER_FIRSTFIRST_TOU_PAI)
    self.waiting_actions = waiting_actions
    for _,action in pairs(self.waiting_actions) do
        self:send_action_waiting(action)
    end

    table.insert(self.game_log.action_table,{
        act = "WaitActions",
        data = table.series(waiting_actions,function(v)
            return {
                chair_id = v.chair_id,
                session_id = v.session_id,
                actions = self:series_action_map(v.actions),
            }
        end),
        time = timer.nanotime()
    })

    local trustee_type,trustee_seconds = self:get_trustee_conf()
    if trustee_type then
        local function auto_action(p,action)
            local act = action.actions[ACTION.ZI_MO] and ACTION.ZI_MO or ACTION.PASS
            local tile = p.mo_pai
            self:lockcall(function()
                self:on_action_after_tou_pai(p,{
                    action = act,
                    value_tile = tile,
                    chair_id = p.chair_id,
                    session_id = action.session_id,
                },true)
            end)
        end

        self:begin_clock_timer(trustee_seconds,function()
            log.dump(self.waiting_actions)
            table.foreach(self.waiting_actions,function(action,_)
                if action.done then return end

                local p = self.players[action.chair_id]
                self:set_trusteeship(p,true)
                auto_action(p,action)
            end)
        end)

        table.foreach(self.waiting_actions,function(action,_) 
            log.dump(self.waiting_actions)
            local p = self.players[action.chair_id]
            if not p.trustee then return end

            self:begin_auto_action_timer(p,math.random(1,2),function() 
                auto_action(p,action)
            end)
        end)
    end
end

function changpai_table:action_after_fan_pai(waiting_actions)
    self:update_state(FSM_S.WAIT_ACTION_AFTER_FAN_PAI)
    self.waiting_actions = waiting_actions
    log.dump(self.waiting_actions)
    for _,action in pairs(self.waiting_actions) do
        self:send_action_waiting(action)
    end

    table.insert(self.game_log.action_table,{
        act = "WaitActions",
        data = table.series(waiting_actions,function(v)
            return {
                chair_id = v.chair_id,
                session_id = v.session_id,
                actions = self:series_action_map(v.actions),
            }
        end),
        time = timer.nanotime()
    })

    local trustee_type,trustee_seconds = self:get_trustee_conf()
    if trustee_type then
        local function auto_action(p,action)
            local act = action.actions[ACTION.ZI_MO] and ACTION.ZI_MO or ACTION.PASS
            local tile = p.mo_pai
            self:lockcall(function()
                self:on_action_after_mo_pai(p,{
                    action = act,
                    value_tile = tile,
                    chair_id = p.chair_id,
                    session_id = action.session_id,
                },true)
            end)
        end

        self:begin_clock_timer(trustee_seconds,function()
            log.dump(self.waiting_actions)
            table.foreach(self.waiting_actions,function(action,_)
                if action.done then return end

                local p = self.players[action.chair_id]
                self:set_trusteeship(p,true)
                auto_action(p,action)
            end)
        end)

        table.foreach(self.waiting_actions,function(action,_) 
            log.dump(self.waiting_actions)
            local p = self.players[action.chair_id]
            if not p.trustee then return end

            self:begin_auto_action_timer(p,math.random(1,2),function() 
                auto_action(p,action)
            end)
        end)
    end
end
function changpai_table:first_action_tianhu(waiting_actions)
    self:update_state(FSM_S.WAIT_ACTION_AFTER_TIAN_HU)
    self.waiting_actions = waiting_actions
    for _,action in pairs(self.waiting_actions) do
        self:send_action_waiting(action)
    end

    table.insert(self.game_log.action_table,{
        act = "WaitActions",
        data = table.series(waiting_actions,function(v)
            return {
                chair_id = v.chair_id,
                session_id = v.session_id,
                actions = self:series_action_map(v.actions),
            }
        end),
        time = timer.nanotime()
    })

    local trustee_type,trustee_seconds = self:get_trustee_conf()
    if trustee_type then
        local function auto_action(p,action)
            local act = action.actions[ACTION.ZI_MO] and ACTION.ZI_MO or ACTION.PASS
            local tile = p.mo_pai
            self:lockcall(function()
                self:on_action_after_mo_pai(p,{
                    action = act,
                    value_tile = tile,
                    chair_id = p.chair_id,
                    session_id = action.session_id,
                },true)
            end)
        end

        self:begin_clock_timer(trustee_seconds,function()
            log.dump(self.waiting_actions)
            table.foreach(self.waiting_actions,function(action,_)
                if action.done then return end

                local p = self.players[action.chair_id]
                self:set_trusteeship(p,true)
                auto_action(p,action)
            end)
        end)

        table.foreach(self.waiting_actions,function(action,_) 
            log.dump(self.waiting_actions)
            local p = self.players[action.chair_id]
            if not p.trustee then return end

            self:begin_auto_action_timer(p,math.random(1,2),function() 
                auto_action(p,action)
            end)
        end)
    end
end
--摸牌后产生的事件，发送给玩家，以及托管玩家的自动响应机制
function changpai_table:action_after_mo_pai(waiting_actions)
    self:update_state(FSM_S.WAIT_ACTION_AFTER_JIN_PAI)
    self.waiting_actions = waiting_actions
    for _,action in pairs(self.waiting_actions) do
        self:send_action_waiting(action)
    end

    table.insert(self.game_log.action_table,{
        act = "WaitActions",
        data = table.series(waiting_actions,function(v)
            return {
                chair_id = v.chair_id,
                session_id = v.session_id,
                actions = self:series_action_map(v.actions),
            }
        end),
        time = timer.nanotime()
    })

    local trustee_type,trustee_seconds = self:get_trustee_conf()
    if trustee_type then
        local function auto_action(p,action)
            local act = action.actions[ACTION.ZI_MO] and ACTION.ZI_MO or ACTION.PASS
            local tile = p.mo_pai
            self:lockcall(function()
                self:on_action_after_mo_pai(p,{
                    action = act,
                    value_tile = tile,
                    chair_id = p.chair_id,
                    session_id = action.session_id,
                },true)
            end)
        end

        self:begin_clock_timer(trustee_seconds,function()
            log.dump(self.waiting_actions)
            table.foreach(self.waiting_actions,function(action,_)
                if action.done then return end

                local p = self.players[action.chair_id]
                self:set_trusteeship(p,true)
                auto_action(p,action)
            end)
        end)

        table.foreach(self.waiting_actions,function(action,_) 
            log.dump(self.waiting_actions)
            local p = self.players[action.chair_id]
            if not p.trustee then return end

            self:begin_auto_action_timer(p,math.random(1,2),function() 
                auto_action(p,action)
            end)
        end)
    end
end

function changpai_table:choice_first_turn_mo_pai(player)
    local fake_mo_pai
    for tile,c in pairs(player.pai.shou_pai) do
        if c > 0 then 
            fake_mo_pai = tile
            break
        end
    end

    player.mo_pai = fake_mo_pai
    return fake_mo_pai
end
function changpai_table:on_reconnect_when_tian_hu(p)
    send2client(p,"SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
    send2client(p,"SC_Changpai_Discard_Round",{chair_id = self.chu_pai_player_index})
    local action = self.waiting_actions[p.chair_id]
    if action and not action.done then
        self:send_action_waiting(action)
    end
    if self.main_timer then
        self:begin_clock(self.main_timer.remainder,p)
    end
end
function changpai_table:on_reconnect_when_first_tou_pai(p)
    send2client(p,"SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
    local action = self.waiting_actions[p.chair_id]
    if action and not action.done then
        self:send_action_waiting(action)
    end
    if self.main_timer then
        self:begin_clock(self.main_timer.remainder,p)
    end
end

function changpai_table:on_reconnect_when_action_after_chu_pai(p)
    send2client(p,"SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
    local action = self.waiting_actions[p.chair_id]
    if action and not action.done then
        self:send_action_waiting(action)
    end
end
function changpai_table:set_palyer_bao_pai(allactions,curpalyer)
    
end
function changpai_table:on_action_after_fan_pai(player,msg,auto)
    log.dump(self.waiting_actions)
    log.dump(msg)
    if not self.waiting_actions then
        log.error("changpai_table:on_action_after_chu_pai not waiting actions,%s",player.guid)
        return
    end
    local fan_tile = msg.value_tile
    if msg.action ==ACTION.PASS and self.chu_pai_player_index ==player.chair_id then
            --包牌判断，假如对下家形成包牌，就返回存在包牌风险提醒，假如下家已经是包牌，那不管
            local nest_user = 1
            if self.chu_pai_player_index+1 > self.start_count then
                nest_user = (self.chu_pai_player_index+1 ) %  self.start_count
            else
                nest_user = (self.chu_pai_player_index+1 )
            end
            local user = self.players[nest_user]
            if  user and not user.is_bao_pai and not user.pai.bao_pai[fan_tile] then
                user.pai.bao_pai[fan_tile] = true
                if self:is_bao_pai(user,fan_tile) then
                        
                    send2client(player,"SC_CP_Canbe_Baopai",{
                        tile = fan_tile,
                    })
                    return
                end
            end
            user.pai.bao_pai[fan_tile] = false
    end
    local action = self:check_action_before_do(self.waiting_actions,player,msg)
    if action then
        local done_action = msg.action
        action.done = {
            action = done_action,
            tile = msg.value_tile,
            other_tile = msg.other_tile,
            auto = auto,
        }
        local chair = action.chair_id
        self:cancel_auto_action_timer(self.players[chair])

        if done_action == ACTION.PASS then

            send2client(player,"SC_Changpai_Do_Action",{
                action = done_action,
                chair_id = player.chair_id,
                session_id = msg.session_id,
            })
        end
    end

    local all_notdone = {}
    local userpri = USER_PRIORITY[self.chu_pai_player_index]
    for k, v in pairs(self.waiting_actions) do
        for i, act in pairs(v.actions) do
            if act then
                table.insert(all_notdone,{ac=i,chairid=v.chair_id})
            end
           
        end
    end
    table.sort(all_notdone,function(l,r)
        return ACTION_PRIORITY[l.ac] < ACTION_PRIORITY[r.ac]
    end)
    table.sort(all_notdone,function(l,r)
        if  ACTION_PRIORITY[l.ac] == ACTION_PRIORITY[r.ac] then
            return userpri[l.chairid] < userpri[r.chairid]
        end
        return ACTION_PRIORITY[l.ac] < ACTION_PRIORITY[r.ac]
    end)
    dump(all_notdone)
    dump(userpri)
    if all_notdone[1].ac == msg.action and all_notdone[1].chairid==player.chair_id then
        dump(all_notdone[1])
    else
        if not table.And(self.waiting_actions,function(action) return action.done ~= nil end) then
            send2client(player,"SC_Changpai_Do_Action_Commit",{
                action = msg.action,
                chair_id = player.chair_id,
                session_id = msg.session_id,
            })
            return
        end
    end


    self:cancel_clock_timer()
    log.dump(self.waiting_actions)
    local all_actions = table.series(self.waiting_actions,function(action)
        return action.done ~= nil and action or nil
    end)


    self.waiting_actions = {}
    local chu_pai_player = self:chu_pai_player()

    table.sort(all_actions,function(l,r)
        if  ACTION_PRIORITY[l.done.action] == ACTION_PRIORITY[r.done.action] then
            return chu_pai_player == l.chair_id
        else
            return ACTION_PRIORITY[l.done.action] < ACTION_PRIORITY[r.done.action]
        end
    end)
    log.dump(all_actions)
    local top_action = all_actions[1]
    local top_session_id = top_action.session_id
    local top_done_act = top_action.done.action
   
    local player = self.players[top_action.chair_id]
    if not player then
        log.error("do action %s,nil player in chair %s",top_action.done.action,top_action.chair_id)
        return
    end
    log.dump(all_actions,"on_action_after_chu_pai"..player.guid)

    log.dump(chu_pai_player.chu_pai)
    local function check_all_pass(actions)
        for _,act in pairs(actions) do
            if act.done.action == ACTION.PASS then
                local p = self.players[act.chair_id]
               
                    local hu_action = act.actions[ACTION.HU]
                    if hu_action then
                        self:set_gzh_on_pass(p,chu_pai_player.fan_pai)
                    end                
               
                    local peng_action = act.actions[ACTION.PENG]
                    if peng_action then
                        self:set_gsp_on_pass(p,chu_pai_player.fan_pai)
                    end

                    local tou_action = act.actions[ACTION.TOU]
                    if tou_action then
                        self:set_gst_on_pass(p,chu_pai_player.fan_pai)
                    end
                    
                    local chi_action = act.actions[ACTION.CHI]
                    if chi_action then
                        self:set_gsc_on_pass(p,chu_pai_player.fan_pai)
                    end
                
            end
        end
    end

    local tile = top_action.done.tile
    local othertile = top_action.done.other_tile
    if top_done_act == ACTION.CHI then      
        table.pop_back(chu_pai_player.pai.desk_tiles)
        self:adjust_shou_pai(player,top_done_act,tile,othertile,top_session_id)
        self:log_game_action(player,top_done_act,tile,top_action.done.auto)
        check_all_pass(all_actions)
        --这里是翻牌以后吃的牌，假如是上家翻牌并且上家可以吃不吃那么这个时候是下加吃牌，形成加番那么在这里设置上家包牌
        if  player.chair_id~=self.chu_pai_player_index then
            local actions1 = self.waiting_actions[self.chu_pai_player_index]
            if actions1 and actions1.actions[ACTION.CHI] and actions1.done.action == ACTION.PASS then
                if self:is_bao_pai(player,tile) then
                   self.players[self.chu_pai_player_index].is_bao_pai = true --玩家对下加形成包牌
                end
            end
            
        end
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:jump_to_player_index(player)
        self:broadcast_discard_turn()
        self:chu_pai()
        log.dump(top_action,"tile"..tile,"othertile"..othertile)
        log.dump(player.pai.shou_pai)
    end

    if top_done_act == ACTION.PENG then
        self:clean_gzh(player)
        table.pop_back(chu_pai_player.pai.desk_tiles)
        self:adjust_shou_pai(player,top_done_act,tile,top_session_id)
        self:log_game_action(player,top_done_act,tile,top_action.done.auto)
        check_all_pass(all_actions)
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:jump_to_player_index(player)
        self:mo_pai()
    end
    if top_done_act == ACTION.TOU then
        self:clean_gzh(player)
        table.pop_back(chu_pai_player.pai.desk_tiles)
        self:adjust_shou_pai(player,top_done_act,tile,top_session_id)
        self:log_game_action(player,top_done_act,tile,top_action.done.auto)
        check_all_pass(all_actions)
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:mo_pai()
    end
    if def.is_action_gang(top_done_act) then
        self:clean_gzh(player)
        table.pop_back(chu_pai_player.pai.desk_tiles)
        self:adjust_shou_pai(player,top_done_act,tile,top_session_id)
        self:log_game_action(player,top_done_act,tile,top_action.done.auto)
        check_all_pass(all_actions)
        self:jump_to_player_index(player)
        self:mo_pai()
        player.statistics.ming_gang = (player.statistics.ming_gang or 0) + 1
    end

    if top_done_act == ACTION.HU then
        local hu_actions = table.series(all_actions,function(act) return act.done.action == ACTION.HU and act or nil end)
        local hu_count_before = table.sum(self.players,function(p) return p.hu and 1 or 0 end)
        if table.nums(hu_actions) > 1 and hu_count_before == 0 then
            chu_pai_player.first_multi_pao = true
        end

        for _,act in pairs(hu_actions) do
            local p = self.players[act.chair_id]
            p.hu = {
                time = timer.nanotime(),
                tile = tile,
                types = self:hu(p,tile),
                zi_mo = false,
                whoee = self.chu_pai_player_index,
            }

            if chu_pai_player.last_action and def.is_action_gang(chu_pai_player.last_action.action) then
                local pai = chu_pai_player.pai
                for _,s in pairs(pai.ming_pai) do
                    if s.tile == chu_pai_player.last_action.tile and def.is_section_gang(s.type) then
                        s.dian_pao = act.chair_id
                    end
                end
            end

            self:log_game_action(p,act.done.action,tile,act.done.auto)
            self:broadcast_player_hu(p,act.done.action,act.session_id)
            p.statistics.hu = (p.statistics.hu or 0) + 1
            chu_pai_player.statistics.dian_pao = (chu_pai_player.statistics.dian_pao or 0) + 1
        end

        table.pop_back(chu_pai_player.pai.desk_tiles)

        check_all_pass(all_actions)

        local hu_count = table.sum(self.players,function(p) return p.hu and 1 or 0 end)
        if  hu_count > 0 then
            self:do_balance()
        end
    end

    if top_done_act == ACTION.PASS then
        check_all_pass(all_actions)
        self:next_player_index()
        --self:fan_pai()
        
        self:begin_main_timer(TIME_TYPE.MAIN_FAN_PAI,TIME_TYPE.MAIN_FAN_PAI,function ()
            self:fan_pai()
        end,"fan_pai")
        return
    end

    self:done_last_action(player,{action = top_done_act,tile = tile})
end
function changpai_table:on_action_after_chu_pai(player,msg,auto)
    if not self.waiting_actions then
        log.error("changpai_table:on_action_after_chu_pai not waiting actions,%s",player.guid)
        return
    end

    local action = self:check_action_before_do(self.waiting_actions,player,msg)
    log.dump(action)
    if action then
        local done_action = msg.action
        action.done = {
            action = done_action,
            tile = msg.value_tile,
            othertile =msg.other_tile,
            auto = auto,
        }
        local chair = action.chair_id
        self:cancel_auto_action_timer(self.players[chair])

        if done_action == ACTION.PASS then
            send2client(player,"SC_Changpai_Do_Action",{
                action = done_action,
                chair_id = player.chair_id,
                session_id = msg.session_id,
            })
        end
    end
   
    local all_notdone = {}
    local userpri = USER_PRIORITY[self.chu_pai_player_index]
    for k, v in pairs(self.waiting_actions) do
        for i, act in pairs(v.actions) do
            if act then
                table.insert(all_notdone,{ac=i,chairid=v.chair_id})
            end
           
        end
    end
    table.sort(all_notdone,function(l,r)
            if  ACTION_PRIORITY[l.ac] == ACTION_PRIORITY[r.ac] then
                return userpri[l.chairid] < userpri[r.chairid]
            else
                return ACTION_PRIORITY[l.ac] < ACTION_PRIORITY[r.ac]
            end
    end)
    dump(all_notdone)
    dump(userpri)
    if all_notdone[1].ac == msg.action and all_notdone[1].chairid==player.chair_id then
        dump(all_notdone[1])
    else
        if not table.And(self.waiting_actions,function(action) return action.done ~= nil end) then
            send2client(player,"SC_Changpai_Do_Action_Commit",{
                action = msg.action,
                chair_id = player.chair_id,
                session_id = msg.session_id,
            })
            return
        end
    end
    self:cancel_clock_timer()
    --所有已经操作的 acitons
    local all_actions = table.series(self.waiting_actions,function(action)
        return action.done ~= nil and action or nil
    end)

    self.waiting_actions = nil

    table.sort(all_actions,function(l,r)
        return ACTION_PRIORITY[l.done.action] < ACTION_PRIORITY[r.done.action]
    end)

    local top_action = all_actions[1]
    local top_session_id = top_action.session_id
    local top_done_act = top_action.done.action
    log.dump(top_done_act)
    local chu_pai_player = self:chu_pai_player()
    local player = self.players[top_action.chair_id]
    if not player then
        log.error("do action %s,nil player in chair %s",top_action.done.action,top_action.chair_id)
        return
    end
    --当玩家按下pass 的时候，要判断这个玩家是否设置成为过庄胡，或者过手碰
    log.dump(all_actions,"on_action_after_chu_pai"..player.guid)
    local function check_all_pass(actions)
        for _,act in pairs(actions) do
            if act.done.action == ACTION.PASS then
                local p = self.players[act.chair_id]
                if self.rule.play.guo_zhuang_hu then
                    local hu_action = act.actions[ACTION.HU]
                    if hu_action then
                        self:set_gzh_on_pass(p,chu_pai_player.chu_pai)
                    end
                end
    
                if self.rule.play.guo_shou_peng then
                    local peng_action = act.actions[ACTION.PENG]
                    if peng_action then
                        self:set_gsp_on_pass(p,chu_pai_player.chu_pai)
                    end
                end
            end
        end
    end

    local tile = top_action.done.tile
    local othertile = top_action.done.othertile
    if top_done_act == ACTION.CHI then
        table.pop_back(chu_pai_player.pai.desk_tiles)
        self:adjust_shou_pai(player,top_done_act,tile,othertile,top_session_id)
        self:log_game_action(player,top_done_act,tile,top_action.done.auto)
        check_all_pass(all_actions)
        --这里是翻牌以后吃的牌，假如是上家翻牌并且上家可以吃不吃那么这个时候是下加吃牌，形成加番那么在这里设置上家包牌
        if self:is_bao_pai(player,tile) then
            self.players[self.chu_pai_player_index].is_bao_pai = true --玩家对下加形成包牌
         end
         local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})

        self:jump_to_player_index(player)
        self:broadcast_discard_turn()
        self:chu_pai()
    end

    if top_done_act == ACTION.PENG then
        self:clean_gzh(player)
        table.pop_back(chu_pai_player.pai.desk_tiles)
        self:adjust_shou_pai(player,top_done_act,tile,top_session_id)
        self:log_game_action(player,top_done_act,tile,top_action.done.auto)
        check_all_pass(all_actions)
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:jump_to_player_index(player)
        self:mo_pai()
    end
    if top_done_act == ACTION.TOU then
        self:clean_gzh(player)
        table.pop_back(chu_pai_player.pai.desk_tiles)
        self:adjust_shou_pai(player,top_done_act,tile,top_session_id)
        self:log_game_action(player,top_done_act,tile,top_action.done.auto)
        check_all_pass(all_actions)
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:mo_pai()
    end
    if def.is_action_gang(top_done_act) then
        self:clean_gzh(player)
        table.pop_back(chu_pai_player.pai.desk_tiles)
        self:adjust_shou_pai(player,top_done_act,tile,top_session_id)
        self:log_game_action(player,top_done_act,tile,top_action.done.auto)
        check_all_pass(all_actions)
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:jump_to_player_index(player)
        self:mo_pai()
        player.statistics.ming_gang = (player.statistics.ming_gang or 0) + 1
    end

    if top_done_act == ACTION.HU then
        local hu_actions = table.series(all_actions,function(act) return act.done.action == ACTION.HU and act or nil end)
        local hu_count_before = table.sum(self.players,function(p) return p.hu and 1 or 0 end)
        if table.nums(hu_actions) > 1 and hu_count_before == 0 then
            chu_pai_player.first_multi_pao = true
        end

        for _,act in pairs(hu_actions) do
            local p = self.players[act.chair_id]
            p.hu = {
                time = timer.nanotime(),
                tile = tile,
                types = self:hu(p,tile),
                zi_mo = false,
                whoee = self.chu_pai_player_index,
            }

            if chu_pai_player.last_action and def.is_action_gang(chu_pai_player.last_action.action) then
                local pai = chu_pai_player.pai
                for _,s in pairs(pai.ming_pai) do
                    if s.tile == chu_pai_player.last_action.tile and def.is_section_gang(s.type) then
                        s.dian_pao = act.chair_id
                    end
                end
            end

            self:log_game_action(p,act.done.action,tile,act.done.auto)
            self:broadcast_player_hu(p,act.done.action,act.session_id)
            p.statistics.hu = (p.statistics.hu or 0) + 1
            chu_pai_player.statistics.dian_pao = (chu_pai_player.statistics.dian_pao or 0) + 1
        end

        table.pop_back(chu_pai_player.pai.desk_tiles)

        check_all_pass(all_actions)

        local hu_count = table.sum(self.players,function(p) return p.hu and 1 or 0 end)
        if hu_count > 0 then
            self:do_balance()
        end
    end

    if top_done_act == ACTION.PASS then
        check_all_pass(all_actions)
        self:next_player_index()
        
        self:begin_main_timer(TIME_TYPE.MAIN_FAN_PAI,TIME_TYPE.MAIN_FAN_PAI,function ()
            self:fan_pai()
        end,"fan_pai")
        --self:fan_pai()
        return
    end

    self:done_last_action(player,{action = top_done_act,tile = tile})
end

function changpai_table:action_after_chu_pai(waiting_actions)
    self:update_state(FSM_S.WAIT_ACTION_AFTER_CHU_PAI)
    self.waiting_actions = waiting_actions
    log.dump(self.waiting_actions)
    for _,action in pairs(self.waiting_actions) do
        self:send_action_waiting(action)
    end

    table.insert(self.game_log.action_table,{
        act = "WaitActions",
        data = table.series(waiting_actions,function(v)
            return {
                chair_id = v.chair_id,
                session_id = v.session_id,
                actions = self:series_action_map(v.actions),
            }
        end),
        time = timer.nanotime()
    })

    local trustee_type,trustee_seconds = self:get_trustee_conf()
    if trustee_type then
        local function auto_action(p,action)
            log.warning("auto action %s",p.guid)
            log.dump(action)
            local act = action.actions[ACTION.HU] and ACTION.HU or ACTION.PASS
            local tile = self:chu_pai_player().chu_pai
            self:lockcall(function()
                self:on_action_after_chu_pai(p,{
                    action = act,
                    value_tile = tile,
                    session_id = action.session_id,
                },true)
            end)
        end

        self:begin_clock_timer(trustee_seconds,function()
            table.foreach(self.waiting_actions,function(action,_)
                local p = self.players[action.chair_id]
                self:set_trusteeship(p,true)
                auto_action(p,action)
            end)
        end)

        table.foreach(self.waiting_actions,function(action,_)
            local p = self.players[action.chair_id]
            if not p.trustee then return end

            self:begin_auto_action_timer(p,math.random(1,2),function()
                auto_action(p,action)
            end)
        end)
    end
end

function changpai_table:fake_mo_pai()
    local player = self:chu_pai_player()
    local shou_pai = player.pai.shou_pai

    local len = self.dealer.remain_count
    log.info("-------left pai " .. len .. " tile")
    if len == 0 then
        self:do_balance()
        return
    end

    local mo_pai
    if table.nums(self.pre_gong_tiles or {}) > 0 then
        for i,tile in pairs(self.pre_gong_tiles) do
            if BTEST then
                mo_pai = tile
            else
                mo_pai = self.dealer:deal_one_on(function(t) return t == tile end)
            end
            self.pre_gong_tiles[i] = nil
            break
        end
    else
        mo_pai = self.dealer:deal_one()
    end

    table.incr(shou_pai,mo_pai)

    player.gzh = nil
    player.gsp = nil
    player.gsc = nil
    self.mo_pai_count = (self.mo_pai_count or 0) + 1
    player.mo_pai_count = (player.mo_pai_count or 0) + 1
end
-----------------过手胡
function changpai_table:clean_gzh(player)
    player.gzh = nil
end

function changpai_table:set_gzh_on_pass(passer,tile)
    passer.gzh = passer.gzh or {}
    passer.gzh[tile] = true
end

function changpai_table:is_in_gzh(player,tile)
    return player.gzh and player.gzh[tile]
end
-----------------过手吃
function changpai_table:clean_gsc(player)
    player.gsc = nil
end

function changpai_table:set_gsc_on_pass(passer,tile)
    passer.gsc = passer.gsc or {}
    passer.gsc[tile] = true
end

function changpai_table:is_in_gsc(player,tile)
    return player.gsc and player.gsc[tile]
end
-----------------
-----------------过手偷
function changpai_table:clean_gst(player)
    player.gst = nil
end

function changpai_table:set_gst_on_pass(passer,tile)
    passer.gst = passer.gst or {}
    passer.gst[tile] = true
end

function changpai_table:is_in_gst(player,tile)
    return player.gst and player.gst[tile]
end
-----------------过手碰
function changpai_table:clean_gsp(player)
    player.gsp = nil
end

function changpai_table:set_gsp_on_pass(passer,tile)
    passer.gsp = passer.gsp or {}
    passer.gsp[tile] = true
end

function changpai_table:is_in_gsp(player,tile)
    return player.gsp and player.gsp[tile]
end

function changpai_table:clean_last_can_penghu(player)
    player.last_penghu  = nil
end 

function changpai_table:get_last_can_penghu(player)
    return player.last_penghu and player.last_penghu.hufan
end
--------------------
-- 手牌最后4张牌,其他玩家出牌是否能操作碰胡,碰后是单吊将
function changpai_table:last_action_is_can_penghu(player,in_pai,allactions,chair_id)
    log.dump(player,"last_action_is_can_penghu_"..player.guid) 
    self:clean_last_can_penghu(player)
    if self.rule.play.guo_zhuang_hu then
        local sum = table.sum(player.pai.shou_pai)
        if sum == 4 then
            local iscanPeng = false
            local iscanHu = false
            for _,act in pairs(allactions) do
                local hu_action = act.actions[ACTION.HU]
                if hu_action then
                    iscanHu = true
                end
                local peng_action = act.actions[ACTION.PENG]
                if peng_action then
                    iscanPeng = true
                end
            end
            if iscanHu and iscanPeng then
                local p = self.players[chair_id]
                p.last_penghu = {
                    can_penghu = true,
                    hufan = self:hu_fan(p,in_pai,nil),
                }     
                log.dump(p.last_penghu,"last_penghu_"..p.guid)           
            end
        end
    end
end
function changpai_table:tou_pai()--偷牌也就是摸牌，但是是在一开始的偷拍阶段 
    local player = self:chu_pai_player()
    local shou_pai = player.pai.shou_pai

    self:clean_gzh(player)
    self:clean_gsp(player)

    local len = self.dealer.remain_count
    log.info("-------left pai " .. len .. " tile")
    if len == 5 then
        self:do_balance()
        return
    end

    local mo_pai
    if table.nums(self.pre_gong_tiles or {}) > 0 then
        for i,tile in pairs(self.pre_gong_tiles) do
            if BTEST then
                mo_pai = tile
            else
                mo_pai = self.dealer:deal_one_on(function(t) return t == tile end)
            end
            self.pre_gong_tiles[i] = nil
            break
        end
    else
        mo_pai = self.dealer:deal_one()
    end

    if not mo_pai then
        self:do_balance()
        return
    end

    self.mo_pai_count = (self.mo_pai_count or 0) + 1
    self:on_mo_pai(player,mo_pai)
    table.incr(shou_pai,mo_pai)
    log.info("---------mo pai,guid:%s,pai:  %s ------",player.guid,mo_pai)
    self:broadcast2client("SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
    tinsert(self.game_log.action_table,{chair = player.chair_id,act = "Draw",msg = {tile = mo_pai}})
    
end
function changpai_table:mo_pai()
    self:update_state(FSM_S.WAIT_MO_PAI)
    local player = self:chu_pai_player()
    local shou_pai = player.pai.shou_pai

    self:clean_gzh(player)
    self:clean_gsp(player)
    self:clean_gsc(player)

    local len = self.dealer.remain_count
    log.info("-------left pai " .. len .. " tile")
    if len == 5 then
        self:do_balance()
        return
    end

    local mo_pai
    if table.nums(self.pre_gong_tiles or {}) > 0 then
        for i,tile in pairs(self.pre_gong_tiles) do
            if BTEST then
                mo_pai = tile
            else
                mo_pai = self.dealer:deal_one_on(function(t) return t == tile end)
            end
            self.pre_gong_tiles[i] = nil
            break
        end
    else
        mo_pai = self.dealer:deal_one()
    end

    if not mo_pai then
        self:do_balance()
        return
    end

    self.mo_pai_count = (self.mo_pai_count or 0) + 1
    
    table.incr(shou_pai,mo_pai)
    log.info("---------mo pai,guid:%s,pai:  %s ------",player.guid,mo_pai)
    self:broadcast2client("SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
    tinsert(self.game_log.action_table,{chair = player.chair_id,act = "Draw",msg = {tile = mo_pai}})
    self:on_mo_pai(player,mo_pai)

    local actions = self:get_actions(player,mo_pai)
    log.dump(actions,tostring(player.guid))
    if table.nums(actions) > 0 then
        self:action_after_mo_pai({
            [self.chu_pai_player_index] = {
                actions = actions,
                chair_id = self.chu_pai_player_index,
                session_id = self:session(),
            }
        })
    else
        self:broadcast_discard_turn()
        self:chu_pai()
    end
end

function changpai_table:ting(p)
    local si_dui = self.rule.play and self.rule.play.si_dui
    local ting_tiles = mj_util.is_ting(p.pai,si_dui) or {}
    if p.que and ting_tiles then
        table.filter(ting_tiles,function(_,tile) return mj_util.tile_men(tile) ~= p.que end)
    end

    return ting_tiles
end

function changpai_table:ting_full(p)
    
    local ting_tiles = mj_util.is_ting_full(p.pai)
    ting_tiles = table.map(ting_tiles,function(tiles,discard)
        local hu_tiles = table.map(tiles,function(_,tile)
            return tile, tile or nil
        end)
        return discard, table.nums(hu_tiles) > 0 and hu_tiles or nil
    end)

    return ting_tiles
end

function changpai_table:broadcast_discard_turn()
    self:broadcast2client("SC_Changpai_Discard_Round",{chair_id = self.chu_pai_player_index})
end

function changpai_table:broadcast_wait_discard(player)
    local chair_id = type(player) == "table" and player.chair_id or player
    self:broadcast2client("SC_ChangpaiWaitingDiscard",{chair_id = chair_id})
end
function changpai_table:on_action_after_jin_pai(player,msg,auto)
end
function changpai_table:on_action_after_first_tou_pai(player,msg,auto)
    local action = self:check_action_before_do(self.waiting_actions,player,msg)
    if not action then 
        log.warning("on_action_after_mo_pai invalid action guid:%s,action:%s",player.guid,msg.action)
        return 
    end

    self:cancel_clock_timer()
    self:cancel_all_auto_action_timer()

    local do_action = msg.action
    local chair_id = player.chair_id
    local tile = msg.value_tile

    if chair_id ~= self.chu_pai_player_index then
        log.error("do action:%s but chair_id:%s is not current chair_id:%s after mo_pai",
            do_action,chair_id,self.chu_pai_player_index)
        return
    end

    log.dump(self.waiting_actions,tostring(player.guid))
    local player = self:chu_pai_player()
    if not player then
        log.error("do action %s,but wrong player in chair %s",do_action,player.chair_id)
        return
    end

    local waiting = self.waiting_actions[player.chair_id]

    local session_id = waiting.session_id

    local player_actions = self.waiting_actions[player.chair_id].actions
    if not player_actions[do_action] and do_action ~= ACTION.PASS and do_action ~= ACTION.CHU_PAI then
        log.error("do action %s,but action is illigle,%s",do_action)
        return
    end

    self.waiting_actions = {}
    --这个改成巴牌
    if do_action == ACTION.BA_GANG then
        self:clean_gzh(player)
        self:adjust_shou_pai(player,do_action,tile,session_id)
        self:log_game_action(player,do_action,tile,auto)
        self:jump_to_player_index(player)
        self:tou_pai() --从桌子上的牌拿一张
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        player.statistics.an_gang = (player.statistics.an_gang or 0) + 1    
        self:action_after_fapai()--假如可以巴牌也要摸一张
    end
     --这个偷牌
     if do_action == ACTION.TOU then
        self:clean_gzh(player)
        self:adjust_shou_pai(player,do_action,tile,session_id)
        self:log_game_action(player,do_action,tile,auto)
        local tuonum = {}
        for chair, p in pairs(self.players) do
            tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
        end
        self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
        self:tou_pai()--从桌子上的牌拿一张   
        self:action_after_fapai()--假如还可以偷牌也要摸一张
    end

    if do_action == ACTION.PASS then
        send2client(player,"SC_Changpai_Do_Action",{
            action = do_action,
            chair_id = player.chair_id,
            session_id = msg.session_id,
        })

         self:next_player_index() --没有actions 跳到下家
        if(self.chu_pai_player_index==self.zhuang) then
            self:action_after_first_tou() --跳回到庄家以后，出牌或者自摸
        else
            self:action_after_fapai()
        end
        return
    end
    self:done_last_action(player,{action = do_action,tile = tile,})
    local tuonum = {}
    for chair, p in pairs(self.players) do
        log.dump(p.pai)
        tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
    end
    log.dump(tuonum)
    self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})
end
function changpai_table:on_action_chu_pai(player,msg,auto)
    if self.cur_state_FSM ~= FSM_S.WAIT_CHU_PAI then
        log.error("changpai_table:on_action_chu_pai state error %s",self.cur_state_FSM)
        return
    end

    if self.chu_pai_player_index ~= player.chair_id then
        log.error("changpai_table:on_action_chu_pai chu_pai_player %s ~= %s",player.chair_id,self.chu_pai_player_index)
        return
    end

    local chu_pai_val = msg.tile

    if not mj_util.check_tile(chu_pai_val) then
        log.error("player %s chu_pai,tile invalid error:%s",self.chu_pai_player_index,chu_pai_val)
        return
    end

    local shou_pai = player.pai.shou_pai
    if not shou_pai[chu_pai_val] or shou_pai[chu_pai_val] == 0 then
        log.error("tile isn't exist when chu guid:%s,tile:%s",player.guid,chu_pai_val)
        return
    end

    --包牌判断，假如对下家形成包牌，就返回存在包牌风险提醒，假如下家已经是包牌，那不管
    local nest_user = 1
    if self.chu_pai_player_index+1 > self.start_count then
        nest_user = (self.chu_pai_player_index+1 ) %  self.start_count
    else
        nest_user = (self.chu_pai_player_index+1 )
    end
    local user = self.players[nest_user]
    if  user and not user.is_bao_pai and not user.pai.bao_pai[chu_pai_val] then
        user.pai.bao_pai[chu_pai_val] = true
        if self:is_bao_pai(user,chu_pai_val) then
                
            send2client(player,"SC_CP_Canbe_Baopai",{
                tile = chu_pai_val,
            })
            return
        end
    end
    log.dump(self.start_count)
    log.dump(nest_user)
    user.pai.bao_pai[chu_pai_val] = false
    --------------------------------------------------------------------------------
    self:cancel_clock_timer()
    self:cancel_all_auto_action_timer()

    log.info("---------chu pai guid:%s,chair: %s,tile:%s ------",player.guid,self.chu_pai_player_index,chu_pai_val)
    shou_pai[chu_pai_val] = shou_pai[chu_pai_val] - 1
    self:on_chu_pai(chu_pai_val)
    tinsert(player.pai.desk_tiles,chu_pai_val)
    self:broadcast2client("SC_Changpai_Action_Discard",{chair_id = player.chair_id, tile = chu_pai_val})
    tinsert(self.game_log.action_table,{chair = player.chair_id,act = "Discard",msg = {tile = chu_pai_val},auto = auto,time = timer.nanotime()})

    local tuonum = {}
    local user={chair=0,tuos=0}
    for chair, p in pairs(self.players) do
        log.dump(p.pai)
        tuonum[p.chair_id] = mj_util.tuos(p.pai,nil,nil,nil)      
    end
    log.dump(tuonum)
    self:broadcast2client("SC_CP_Tuo_Num",{ tuos = tuonum})

    local waiting_actions = {}
    self:foreach_except(player,function(v)
        if nest_user ==  v.chair_id then
            local actions = self:get_actions(v,nil,chu_pai_val,nil,true,true)
            if table.nums(actions) > 0 then
                waiting_actions[v.chair_id] = {
                    chair_id = v.chair_id,
                    actions = actions,
                    session_id = self:session(),
                }
            end
        else
            local actions = self:get_actions(v,nil,chu_pai_val,nil,nil,true)
            if table.nums(actions) > 0 then
                waiting_actions[v.chair_id] = {
                    chair_id = v.chair_id,
                    actions = actions,
                    session_id = self:session(),
                }
            end
        end
        
    end)

    log.dump(waiting_actions)
    if table.nums(waiting_actions) == 0 then
        self:next_player_index()
        
        self:begin_main_timer(TIME_TYPE.MAIN_FAN_PAI,TIME_TYPE.MAIN_FAN_PAI,function ()
            self:fan_pai()
        end,"fan_pai")
        
    else
        self:action_after_chu_pai(waiting_actions)
    end
end
function changpai_table:is_bao_pai(player,in_pai)
    local tileNum = 0
        for index, s in ipairs(player.pai.ming_pai) do
           if s.tile == in_pai and (s.type == SECTION_TYPE.PENG or  s.type == SECTION_TYPE.TOU)  then
                return true
           end 
           if s.type == SECTION_TYPE.CHI and s.thertile == in_pai then
                tileNum= tileNum+1
           end
        end
        if  tileNum >=2 then
            return true
        end
    return  false
end
function changpai_table:send_ting_tips(p)
    local hu_tips = self.rule and self.rule.play.hu_tips or nil
    if not hu_tips or p.trustee then return end

    local ting_tiles = self:ting_full(p)
    if table.nums(ting_tiles) > 0 then
        local pai = p.pai
        local discard_tings = table.series(ting_tiles,function(tiles,discard)--把可以胡的牌放到手牌中算翻发给前端
            table.decr(pai.shou_pai,discard)
            local tings = table.series(tiles,function(_,tile) return {tile = tile,fan = self:hu_fan(p,tile)} end)
            table.incr(pai.shou_pai,discard)
            return { discard = discard, tiles_info = tings, }
        end)

        send2client(p,"SC_CP_TingTips",{
            ting = discard_tings
        })
    end
end

function changpai_table:on_reconnect_when_chu_pai(p)
    send2client(p,"SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
    send2client(p,"SC_Changpai_Discard_Round",{chair_id = self.chu_pai_player_index})
    self:send_ting_tips(p)

    if self.main_timer then
        self:begin_clock(self.main_timer.remainder,p)
    end
end
function changpai_table:call_chu_pai(p)
    send2client(p,"SC_Changpai_Discard_Round",{chair_id = self.chu_pai_player_index})
end
function changpai_table:chu_pai()
    local player = self:chu_pai_player()
    self:call_chu_pai(player)
    self:update_state(FSM_S.WAIT_CHU_PAI)

    
    local trustee_type,trustee_seconds = self:get_trustee_conf()
    if trustee_type then
        local function auto_chu_pai(p)
            local chu_tile = p.mo_pai
            if p.que then
                local men_tiles = table.group(p.pai.shou_pai,function(_,tile) return mj_util.tile_men(tile) end)

                log.dump(men_tiles)
                if men_tiles[p.que] and table.sum(men_tiles[p.que]) > 0 then
                    local c
                    repeat
                        chu_tile,c = table.choice(men_tiles[p.que])
                        log.info("%d,%d",chu_tile,c)
                    until c and c > 0
                end
            end

            if not chu_tile or not p.pai.shou_pai[chu_tile] or p.pai.shou_pai[chu_tile] <= 0 then
                local c
                repeat
                    chu_tile,c = table.choice(p.pai.shou_pai)
                until c > 0
            end

            log.info("auto_chu_pai chair_id %s,tile %s",p.chair_id,chu_tile)
            self:lockcall(function()
                self:on_action_chu_pai(p,{
                    tile = chu_tile,
                },true)
            end)
        end

        log.info("begin chu_pai clock %s",player.chair_id)
        self:begin_clock_timer(trustee_seconds,function()
            log.info("chu_pai clock timeout %s",player.chair_id)
            self:set_trusteeship(player,true)
            auto_chu_pai(player)
        end)

        if player.trustee then
            log.info("begin auto_chu_pai timer %s",player.chair_id)
            self:begin_auto_action_timer(player,math.random(1,2),function()
                log.info("auto_chu_pai timeout %s",player.chair_id)
                auto_chu_pai(player)
            end)
        end
    end

    self:send_ting_tips(player)
end
function changpai_table:fan_pai()
    
    local player = self:chu_pai_player()
    local shou_pai = player.pai.shou_pai

    self:clean_gzh(player)
    self:clean_gsp(player)

    local len = self.dealer.remain_count
    log.info("-------left pai " .. len .. " tile")
    if len == 5 then
        self:do_balance()
        return
    end

    local fan_pai
    if table.nums(self.pre_gong_tiles or {}) > 0 then
        for i,tile in pairs(self.pre_gong_tiles) do
            if BTEST then
                fan_pai = tile
            else
                fan_pai = self.dealer:deal_one_on(function(t) return t == tile end)
            end
            self.pre_gong_tiles[i] = nil
            break
        end
    else
        fan_pai = self.dealer:deal_one()
    end

    if not fan_pai then
        self:do_balance()
        return
    end

    self.mo_pai_count = (self.mo_pai_count or 0) + 1
    
    --table.incr(shou_pai,mo_pai)
    log.info("---------mo pai,guid:%s,pai:  %s ------",player.guid,fan_pai)
    self:broadcast2client("SC_Changpai_Tile_Left",{tile_left = self.dealer.remain_count,})
    tinsert(self.game_log.action_table,{chair = player.chair_id,act = "Draw",msg = {tile = fan_pai}})
    self:on_fan_pai(player,fan_pai)

    self:on_user_fan_pai(fan_pai)
    --翻牌的时候所有玩家都可以相应action
    local waiting_actions = {}
 
    self:foreach(function(v)   
            if player.chair_id == v.chair_id then 
                -- 自己出牌,判断自己打出的这张牌自己是否能碰胡(过庄胡、过手碰)需要
                log.info("--- get_selfactionsAndset_pass  guid:%s,chair: %s,tile:%s ------",player.guid,self.chu_pai_player_index,fan_pai)
                --local selfactions = self:get_selfactionsAndset_pass(v,fan_pai)
                --log.dump(selfactions,"get_selfactionsAndset_pass guid_"..player.guid)
                self:clean_last_can_penghu(player)
                local actions = self:get_actions(v,nil,fan_pai,nil,true)
                if table.nums(actions) > 0 then
                    waiting_actions[v.chair_id] = {
                        chair_id = v.chair_id,
                        actions = actions,
                        session_id = self:session(),
                    }
                end
            else    
                local nestchair=(player.chair_id+1) % self.chair_count
                    if nestchair ==v.chair_id then --下家可吃牌
                        local actions = self:get_actions(v,nil,fan_pai,nil,true)
                        if table.nums(actions) > 0 then
                        waiting_actions[v.chair_id] = {
                            chair_id = v.chair_id,
                            actions = actions,
                            session_id = self:session(),
                        }
                    else
                        local actions = self:get_actions(v,nil,fan_pai)
                        if table.nums(actions) > 0 then                           
                            waiting_actions[v.chair_id] = {
                            chair_id = v.chair_id,
                            actions = actions,
                            session_id = self:session(),
                        }
                    end
                end
             end 
        end
        
    end)

    log.dump(waiting_actions)
    if table.nums(waiting_actions) == 0 then
        self:next_player_index()
        
        self:begin_main_timer(TIME_TYPE.MAIN_FAN_PAI,TIME_TYPE.MAIN_FAN_PAI,function ()
            self:fan_pai()
        end,"fan_pai")
        --self:fan_pai()
    else
    end
    self:action_after_fan_pai(waiting_actions)

end    
function changpai_table:get_max_fan()
    local fan_opt = self.rule.fan.max_option + 1
    return self.room_.conf.private_conf.fan.max_option[fan_opt]
end

function changpai_table:do_balance()
    local typefans,fanscores = self:game_balance()
    log.dump(typefans)
    log.dump(fanscores)
    local msg = {
        players = {},
        player_balance = {},
    }

    local ps = table.values(self.players)
    table.sort(ps,function(l,r)
        if l.hu and not r.hu then return true end
        if not l.hu and r.hu then return false end
        if l.hu and r.hu then return l.hu.time < r.hu.time end
        return false
    end)

    table.foreach(ps,function(p,i)
        if p.hu then p.hu.index = i end
    end)


    local chair_money = {}
    for chair_id,p in pairs(self.players) do
        local p_score = fanscores[chair_id] and fanscores[chair_id].score or 0
        local shou_pai = self:tile_count_2_tiles(p.pai.shou_pai)
        local ming_pai = table.values(p.pai.ming_pai)
        local desk_pai = table.values(p.pai.desk_tiles)
        local p_log = self.game_log.players[chair_id]
        p_log.chair_id = chair_id
        p_log.nickname = p.nickname
        p_log.head_url = p.icon
        p_log.guid = p.guid
        p_log.sex = p.sex
        p_log.pai = {
            desk_pai = desk_pai,
            shou_pai = shou_pai,
            ming_pai = ming_pai,
            huan = p.pai.huan,
        }

        p.total_score = (p.total_score or 0) + p_score
        p_log.score = p_score

        tinsert(msg.players,{
            chair_id = chair_id,
            desk_pai = desk_pai,
            shou_pai = shou_pai,
            pb_ming_pai = ming_pai,
        })

        tinsert(msg.player_balance,{
            chair_id = chair_id,
            total_score = p.total_score,
            round_score = p_score,
            items = typefans[chair_id],
            hu_tile = p.hu and p.hu.tile or nil,
            hu_fan = fanscores[chair_id].fan,
            hu = p.hu and (p.hu.zi_mo and 2 or 1) or nil,
            status = p.hu and 2  or nil,
            hu_index = p.hu and p.hu.index or nil,
        })

        local win_money = self:calc_score_money(p_score)
        chair_money[chair_id] = win_money
        log.info("player hu %s,%s,%s",chair_id,p_score,win_money)
    end

    log.dump(msg)

    local logids = {
        [350] = enum.LOG_MOENY_OPT_TYPE_CHANGPAI_SICHUAN,
    }

    chair_money = self:balance(chair_money,logids[def_first_game_type])
    for _,balance in pairs(msg.player_balance) do
        local p = self.players[balance.chair_id]
        local p_log = self.game_log.players[balance.chair_id]
        local money = chair_money[balance.chair_id]
        balance.round_money = money
        p.total_money = (p.total_money or 0) + money
        balance.total_money = p.total_money
        p_log.total_money = p.total_money
        p_log.win_money = money
    end 
    
    msg.leftpai = self.dealer:deal_tiles(self.dealer.remain_count)
    self:broadcast2client("SC_ChangpaiGameFinish",msg)

    self:notify_game_money()

    self.game_log.balance = msg.player_balance
    self.game_log.end_game_time = os.time()
    self.game_log.cur_round = self.cur_round

    self:save_game_log(self.game_log)

    self.game_log = nil
    
    self:game_over()
end

function changpai_table:pre_begin()
    self:xi_pai()
end

function changpai_table:series_action_map(actions)
    log.dump(actions)
    local acts = {}
    for act,tiles in pairs(actions) do
        for tile,v in pairs(tiles) do   
                tinsert(acts,{
                    action = act,
                    tile = v.tile,   
                    other_tile = v.othertile or nil,  
                })
        end
    end
    log.dump(acts)
    return acts
end

function changpai_table:send_action_waiting(action)
    local chair_id = action.chair_id
    log.info("send_action_waiting,%s",chair_id)
    send2client(self.players[chair_id],"SC_CP_WaitingDoActions",{
        chair_id = chair_id,
        actions = self:series_action_map(action.actions),
        session_id = action.session_id,
    })
end

function changpai_table:prepare_tiles()
    if not BTEST then
        self.dealer:shuffle()
        self.pre_tiles = {}
    else   
        self.zhuang = 1
        self.chu_pai_player_index = self.zhuang --出牌人的索引
        self.dealer.remain_count = 108
        -- 测试手牌     
        self.pre_tiles = {
            [1] = {2,5,8,9,14,15,15,17,17,18,25,26,26},     -- 万 庄
            [2] = {3,3,4,22,22,22,23,23,27,27,27,28,29},    -- 筒  
            [3] = {2,3,4,5,8,12,12,13,13,13,17,18,19},      -- 万
            [4] = {2,2,6,7,9,9,12,13,14,16,18,19,26},       -- 条
        }
        -- 测试摸牌,从前到后
        self.pre_gong_tiles = {
            29,24,6,1,17,24,22,23,21,25,25,17,1,7,22,12,17,24,25,27,29,
        }
    end
    self.zhuang_pai = self.dealer:deal_one()
    if self.start_count == 2 then
        self.qie_pai = self.dealer:deal_tiles(15) 
    end
    log.info("zhuang_pai %d  ",self.zhuang_pai)
    self.zhuang = mj_util.tile_value(self.zhuang_pai) % (self.start_count)+1

    self:foreach(function(p)--给每个玩家发牌
        local tiles = self.pre_tiles[p.chair_id]
        if tiles then
            self.dealer:pick_tiles(tiles)
        end

        local c = table.nums(tiles or {})
        if c < self.game_tile_count then
            tiles = table.union(tiles or {},self.dealer:deal_tiles(self.game_tile_count - c))
        end

        for _,t in pairs(tiles) do
            table.incr(p.pai.shou_pai,t)
        end
    end)

    self.chu_pai_player_index = self.zhuang
    log.info("user   %d",self.chu_pai_player_index)
    self:fake_mo_pai()--庄家多摸一张牌 也就是16张牌
end


function changpai_table:serial_types(tsmap)
    local types = table.series(tsmap,function(c,t)
        local tinfo = HU_TYPE_INFO[t]
        return {type = t,fan = tinfo.fan,score = tinfo.score,count = c}
    end)

    return types
end

function changpai_table:gang_types(p)
    local s2hu_type = {
        [SECTION_TYPE.CHONGFAN_PENG] = HU_TYPE.CHONGFAN_PENG,
        [SECTION_TYPE.SI_ZHANG] = HU_TYPE.SI_ZHANG,
        [SECTION_TYPE.TUO_24] = HU_TYPE.TUO_24,
        [SECTION_TYPE.CHONGFAN_TOU] = HU_TYPE.CHONGFAN_TOU,
        [SECTION_TYPE.CHONGFAN_CHI_3] = HU_TYPE.CHONGFAN_CHI_3,
    }

    local ss = table.select(p.pai.ming_pai,function(s) return  s2hu_type[s.type] ~= nil end)
    local gfan= table.group(ss,function(s) return  s2hu_type[s.type] end)
    local typescount = table.map(gfan,function(gp,t)
        return t,table.nums(gp)
    end)

    return typescount --算出明牌中有这些动作的种类和数量 [HU_TYPE]=counts
end

function changpai_table:calc_types(ts)
    ts = self:serial_types(ts)
    return table.sum(ts,function(t) return (t.score or 1) * (t.count or 0) end),
        table.sum(ts,function(t) return (t.count or 1) * (t.fan or 0) end)
end

function changpai_table:hu_fan(player,in_pai,mo_pai,qiang_gang)
    local rule_hu = self:rule_hu(player.pai,in_pai,mo_pai,player.chair_id==self.zhuang)
    local ext_hu = self:ext_hu(player,mo_pai,qiang_gang)
    local hu = table.merge(rule_hu,ext_hu,function(l,r) return l or r end)
    local types = table.merge(hu,self:gang_types(player),function(l,r) return l or r end)
    local score,fan = self:calc_types(types)
    return fan or 0,score or 0
end

function changpai_table:get_actions_first_turn(p,mo_pai)
   
    local actions = mj_util.get_actions_first_turn(p.pai,mo_pai)
    log.dump(actions)
    return actions
end

function changpai_table:get_actions(p,mo_pai,in_pai,qiang_gang,can_eat,chupai_index)  

    log.dump(p)

    local actions = mj_util.get_actions(p.pai,mo_pai,in_pai,can_eat,chupai_index)

    log.dump(actions,tostring(p.guid))

    
    --坨数不够的时候也不能胡
    if in_pai and not self:can_hu(p,in_pai,nil,qiang_gang) and actions[ACTION.HU] then
        log.info("get_actions in_pai %d not can_hu ",in_pai)
        actions[ACTION.HU] = nil
    end
    if in_pai and self:is_in_gsp(p,in_pai) and actions[ACTION.ZI_MO] then
        local action = actions[ACTION.ZI_MO]
        for gsh_tile,_ in pairs(p.gsh) do
            action[gsh_tile] = nil
        end
        if table.nums(action) == 0 then
            actions[ACTION.ZI_MO] = nil
        end
    end
    if in_pai and self:is_in_gsp(p,in_pai) and actions[ACTION.PENG] then
        local action = actions[ACTION.PENG]
        for gsp_tile,_ in pairs(p.gsp) do
            action[gsp_tile] = nil
        end
        if table.nums(action) == 0 then
            actions[ACTION.PENG] = nil
        end
    end
    if in_pai and self:is_in_gsc(p,in_pai) and actions[ACTION.CHI] then
        local action = actions[ACTION.CHI]
        for gsc_tile,_ in pairs(p.gsc) do
            action[gsc_tile] = nil
        end
        if table.nums(action) == 0 then
            actions[ACTION.CHI] = nil
        end
    end
    if in_pai and self:is_in_gzh(p,in_pai) and actions[ACTION.HU] then
        local action = actions[ACTION.HU]
        for gsh_tile,_ in pairs(p.gsh) do
            action[gsh_tile] = nil
        end
        if table.nums(action) == 0 then
            actions[ACTION.HU] = nil
        end
    end
    if in_pai and mj_util.tile_value(in_pai) == 7 then
        actions[ACTION.HU] = nil
    end
    local remain = self.dealer.remain_count
    if remain <= 5 then
        actions[ACTION.BA_GANG] = nil
        actions[ACTION.HU] = nil
        actions[ACTION.PENG] = nil
        actions[ACTION.CHI] = nil
        actions[ACTION.TOU] = nil
        actions[ACTION.ZI_MO] = nil
    end

    return actions
end
-- 自己出牌,判断是否过庄胡、过手碰
function changpai_table:get_selfactionsAndset_pass(p,in_pai)
    local actions
    if self.rule.play.guo_zhuang_hu or self.rule.play.guo_shou_peng then
        actions = self:get_actions(p,nil,in_pai,nil,nil)
        if table.nums(actions) > 0 then
            if self.rule.play.guo_zhuang_hu then
                local hu_action = actions[ACTION.HU]
                if hu_action then
                    self:set_gzh_on_pass(p,in_pai)
                    local last_penghu = self:get_last_can_penghu(p)
                    log.dump(last_penghu,"last_penghu_"..p.guid)
                    if last_penghu then
                        p.gzh[in_pai] = last_penghu
                        log.dump(p.gzh,"newgzh"..tostring(p.guid))
                    end
                end
            end

            if self.rule.play.guo_shou_peng then
                local peng_action = actions[ACTION.PENG]
                if peng_action then
                    self:set_gsp_on_pass(p,in_pai)
                end
            end
            if self.rule.play.guo_shou_chi then
                local peng_action = actions[ACTION.CHI]
                if peng_action then
                    self:set_gsc_on_pass(p,in_pai)
                end
            end
        end
    end

    return actions
end

local action_name_str = {  
    [ACTION.PENG] = "Peng", 
    [ACTION.BA_GANG] = "BaGang",
    [ACTION.ZI_MO] = "ZiMo",
    [ACTION.CHI] = "Chi",
    [ACTION.JIA_BEI] = "JiaBei",
    [ACTION.TRUSTEE] = "Trustee",
    [ACTION.PASS] = "Pass",
    [ACTION.HU] = "Hu",
    [ACTION.TING] = "Ting",
    [ACTION.CHU_PAI] = "Discard",
    [ACTION.MO_PAI] = "Draw",
    [ACTION.QIANG_GANG_HU] = "QiangGangHu",
}

function changpai_table:log_game_action(player,action,tile,auto)
    tinsert(self.game_log.action_table,{chair = player.chair_id,act = action_name_str[action],msg = {tile = tile},auto = auto,time = timer.nanotime()})
end

function changpai_table:log_failed_game_action(player,action,tile,auto)
    tinsert(self.game_log.action_table,{chair = player.chair_id,act = action_name_str[action],msg = {tile = tile},auto = auto,failed = true,})
end

function changpai_table:done_last_action(player,action)
    player.last_action = action
    self:foreach_except(player,function(p) p.last_action = nil end)
end

function changpai_table:check_action_before_do(waiting_actions,player,msg)
    local action = msg.action
    local chair_id = player.chair_id
    local tile = msg.value_tile

    log.dump(msg)
    log.dump(waiting_actions)
    if not waiting_actions then
        log.error("waiting actions nil when check_action_before_do,chair_id %s,action:%s,tile:%s",chair_id,action,tile)
        return
    end

    local player_actions = waiting_actions[chair_id]
    if not player_actions then
        log.error("no action waiting when check_action_before_do,chair_id %s,action:%s,tile:%s",chair_id,action,tile)
        return
    end

    if player_actions.session_id ~= msg.session_id then
        log.error("action session id %s,%s when check_action_before_do,chair_id %s,action:%s,tile:%s",
            player_actions.session_id,msg.session_id,chair_id,action,tile)
        return
    end

    local actions = player_actions.actions
    log.dump(player_actions)
    if not actions then
        log.error("on action %s,%s,actions is nil",chair_id,tile)
        return
    end

    if action == ACTION.PASS then
        return player_actions
    end

    if def.is_action_gang(action) then
        if not actions[action] or not actions[action][tile] then
            log.error("no action waiting when check_action_before_do,chair_id %s,action:%s,tile:%s",chair_id,action,tile)
            return
        end
    end

    if not actions[action]  then
        log.error("no action waiting when check_action_before_do,chair_id %s,action:%s,tile:%s",chair_id,action,tile)
        return
    end

    return player_actions
end

function changpai_table:on_fan_pai(player,fan_pai)
    player.fan_pai = fan_pai
    player.mo_pai_count = (player.mo_pai_count or 0) + 1
    send2client(player,"SC_Changpai_Fan",{tile = fan_pai,chair_id = player.chair_id})
    self:foreach_except(player,function(p)
        send2client(p,"SC_Changpai_Fan",{tile = fan_pai,chair_id = player.chair_id})
        p.fan_pai = nil
    end)
end
function changpai_table:on_mo_pai(player,mo_pai)
    player.mo_pai = mo_pai
    player.mo_pai_count = (player.mo_pai_count or 0) + 1
    send2client(player,"SC_Changpai_Draw",{tile = mo_pai,chair_id = player.chair_id})
    self:foreach_except(player,function(p)
        send2client(p,"SC_Changpai_Draw",{tile = 255,chair_id = player.chair_id})
        p.mo_pai = nil
    end)
end

function changpai_table:calculate_hu(hu)
    return self:serial_types(hu.types)
end



function changpai_table:calculate_gang(p)
    local s2hu_type = {
        [SECTION_TYPE.PENG] = HU_TYPE.CHONGFAN_PENG,
        [SECTION_TYPE.TOU] = HU_TYPE.CHONGFAN_TOU,
        [SECTION_TYPE.CHI_3] = HU_TYPE.CHONGFAN_CHI_3,  
        [SECTION_TYPE.SI_ZHANG] = HU_TYPE.SI_ZHANG,  
        [SECTION_TYPE.TUO24] = HU_TYPE.Tuo24,  
    }
    local chong_fan ={--冲番牌
        [1] = true,
        [3] = true,
        [5] = true,
        [12] = true,
        [15] = true,
        [17] = true,
        [21] = true,
    }
    local scores = {}

    --统计出冲番牌的碰和头
    
    local ss = table.select(p.pai.ming_pai,function(s) return  s2hu_type[s.type] ~= nil and chong_fan[s.tile] end)

    


    local gfan= table.group(ss,function(s) return  s2hu_type[s.type] end)

    

    local gangfans = table.map(gfan,function(gp,t)
        return t,{fan = HU_TYPE_INFO[t].fan,count = table.nums(gp)}
    end)
    
    local chi_pai = {}
    for _, s in pairs(p.pai.ming_pai) do      
        local count={}

        if s.type == SECTION_TYPE.CHI then
            if chi_pai[s.tile] then chi_pai[s.tile]=chi_pai[s.tile]+1 
            else chi_pai[s.tile]=1 end   
        end



        if  s.type == SECTION_TYPE.BA_GANG  then    
              
            if gangfans[HU_TYPE.SI_ZHANG] then gangfans[HU_TYPE.SI_ZHANG].count=gangfans[HU_TYPE.SI_ZHANG].count+1
            else gangfans[HU_TYPE.SI_ZHANG]={fan = HU_TYPE_INFO[HU_TYPE.SI_ZHANG].fan,count = 1} end
        end

        if s.type == SECTION_TYPE.PENG or s.type == SECTION_TYPE.TOU then 
            if chong_fan[s.tile]  and s.type == SECTION_TYPE.PENG then--假如是冲番牌
                if gangfans[HU_TYPE.CHONGFAN_PENG] then gangfans[HU_TYPE.CHONGFAN_PENG].count=gangfans[HU_TYPE.CHONGFAN_PENG].count+1
                else gangfans[HU_TYPE.CHONGFAN_PENG]={fan = HU_TYPE_INFO[HU_TYPE.CHONGFAN_PENG].fan,count = 1} end
            elseif  chong_fan[s.tile]  and s.type == SECTION_TYPE.TOU then 
                if gangfans[HU_TYPE.CHONGFAN_TOU] then gangfans[HU_TYPE.CHONGFAN_TOU].count=gangfans[HU_TYPE.CHONGFAN_TOU].count+1
                else gangfans[HU_TYPE.CHONGFAN_TOU]={fan = HU_TYPE_INFO[HU_TYPE.CHONGFAN_TOU].fan,count = 1} end
            end
            count[s.tile]=3
            for index, x in pairs(p.pai.shou_pai) do
                if index==s.tile and x>0 then 
                    count[s.tile]=count[s.tile]+ x
                end
                
            end
        end
        if count[s.tile]==4 then 
            if gangfans[HU_TYPE.SI_ZHANG] then gangfans[HU_TYPE.SI_ZHANG].count=gangfans[HU_TYPE.SI_ZHANG].count+1
            else gangfans[HU_TYPE.SI_ZHANG]={fan = HU_TYPE_INFO[HU_TYPE.SI_ZHANG].fan,count = 1} end
        end

        for index, x in pairs(p.pai.shou_pai) do
            if x==4 then 
                if gangfans[HU_TYPE.SI_ZHANG] then gangfans[HU_TYPE.SI_ZHANG].count=gangfans[HU_TYPE.SI_ZHANG].count+1
                else gangfans[HU_TYPE.SI_ZHANG]={fan = HU_TYPE_INFO[HU_TYPE.SI_ZHANG].fan,count = 1} end
            end
            
        end
        

    
    end

    for tile, value in ipairs(chi_pai) do
        if value>=3 then
        if gangfans[HU_TYPE.CHONGFAN_CHI_3] then gangfans[HU_TYPE.CHONGFAN_CHI_3].count=gangfans[HU_TYPE.CHONGFAN_CHI_3].count+1
        else gangfans[HU_TYPE.CHONGFAN_CHI_3]={fan = HU_TYPE_INFO[HU_TYPE.CHONGFAN_CHI_3].fan,count = 1} end
        end
    end

    local fans = table.series(gangfans,function(v,t) return {type = t,fan = v.fan,count = v.count} end)
    return fans,scores
end

function changpai_table:calculate_jiao(p)
    if not p.jiao then return end

    local jiao_tiles = p.jiao.tiles
    if table.nums(jiao_tiles) == 0 then 
        return {} 
    end

    local type_fans = table.flatten(
        table.series(jiao_tiles,function(_,tile)
            local tt = self:rule_hu_types(p.pai,tile,p.chair_id==self.zhuang)
            return table.series(tt,function(ts)
                local _,fan = self:calc_types(ts)
                return {types = self:serial_types(ts),fan = fan,tile = tile}
            end)
        end)
    )
    
    if self.rule.play.cha_da_jiao then
        table.sort(type_fans,function(l,r) return l.fan > r.fan end)
    elseif self.rule.play.cha_xiao_jiao then
        table.sort(type_fans,function(l,r) return l.fan < r.fan end)
    end

    return type_fans[1]
end


function changpai_table:game_balance()
    --没有胡的人数
    local wei_hu_count = table.sum(self.players,function(p) return (not p.hu) and 1 or 0 end)

    log.dump(wei_hu_count)

    local typefans,scores = {},{}
    self:foreach(function(p)
        log.dump( p.hu)
        local hu
        if p.hu then
            hu = self:calculate_hu(p.hu) --统计番数，胡的类型数，胡的分数
        end
        log.dump(hu)
        local gangfans,gangscores
        if  p.hu then
            gangfans,gangscores = self:calculate_gang(p) --只要有人胡杠什么的就要算钱
        end
        log.dump(gangfans)
        log.dump(gangscores)
        typefans[p.chair_id] = table.union(hu or {},gangfans or {})
        table.mergeto(scores,gangscores or {},function(l,r) return (l or 0) + (r or 0) end)
    end)

    log.dump(typefans)

    local max_fan = self:get_max_fan() or 3
    log.dump(max_fan)
    local fans = table.map(typefans,function(v,chair)
        local fan = table.sum(v,function(t) return t.fan * t.count end)
        return chair,(fan > max_fan and max_fan or fan)
    end)
    log.dump(fans)

    self:foreach(function(p)
        local chair_id = p.chair_id
        local fan = fans[chair_id]
        local fan_score = 2 ^ math.abs(fan)
        log.dump(fan_score)
        log.dump(p.hu)
        if p.hu then
            if not p.hu.zi_mo then
                local whoee = p.hu.whoee
                scores[whoee] = (scores[whoee] or 0) - fan_score
                scores[chair_id] = (scores[chair_id] or 0) + fan_score
                return
            end

            if self.rule.play.zi_mo_jia_di then
                fan_score = fan_score + 1
            end

            self:foreach_except(p,function(pi)
                if pi.hu and pi.hu.time <= p.hu.time then return end

                local chair_i = pi.chair_id
                scores[chair_i] = (scores[chair_i] or 0) - fan_score
                scores[chair_id] = (scores[chair_id] or 0) + fan_score
            end)
            self:foreach_except(p,function(pi)
                if pi.hu or pi.jiao then return end
                local chair_i = pi.chair_id
                scores[chair_id] = (scores[chair_id] or 0) + fan_score
                scores[chair_i] = (scores[chair_i] or 0) - fan_score
            end)
        end
    end)

    local fanscores = table.map(self.players,function(_,chair)
        return chair,{fan = fans[chair] or 0,score = scores[chair] or 0,}
    end)
    log.dump(typefans)
    log.dump(fanscores)
    return typefans,fanscores
end

function changpai_table:on_game_overed()
    self:cancel_all_auto_action_timer()
    self:cancel_clock_timer()
    
    self.game_log = nil

    self.zhuang = self:ding_zhuang() or self.zhuang

    self:clear_ready()
    self.cur_state_FSM = nil

    self:foreach(function(v)
        v.hu = nil
        v.jiao = nil
        v.pai = {
            ming_pai = {},
            shou_pai = {},
            desk_tiles = {},
            huan = nil,
        }
        v.mo_pai = nil
        v.mo_pai_count = nil
        v.chu_pai = nil
        v.fan_pai = nil
        v.chu_pai_count = nil

        v.que = nil
    end)

    base_table.on_game_overed(self)
end

function changpai_table:on_process_start(player_count)
    base_table.on_process_start(self,player_count)
end

function changpai_table:on_process_over(reason)
    self:broadcast2client("SC_Changpai_Final_Game_Over",{
        players = table.series(self.players,function(p,chair)
            return {
                chair_id = chair,
                guid = p.guid,
                score = p.total_score or 0,
                money = p.total_money or 0,
                statistics = table.series(p.statistics or {},function(c,t) return {type = t,count = c} end),
            }
        end),
    })

    local total_winlose = table.map(self.players,function(p) return p.guid,p.total_money or 0 end)

    self:cost_tax(total_winlose)

    for _,p in pairs(self.players) do
        p.total_money = nil
        p.round_money = nil
        p.total_score = nil
    end

    self.zhuang = nil
    self.zhuang_pai = nil
    self.cur_state_FSM = nil
    self.qie_pai = nil
	base_table.on_process_over(self,reason,{
        balance = total_winlose,
    })

    self:foreach(function(p)
        p.statistics = nil
    end)
end

function changpai_table:ding_zhuang()
    if not self.zhuang then
        return
    end

    local hu_count = table.sum(self.players,function(p) return p.hu and 1 or 0 end)
    if hu_count == 0 then
        return
    end

    for _,p in pairs(self.players) do
        if p.first_multi_pao then
            return p.chair_id
        end
    end

    local ps = table.values(self.players)
    table.sort(ps,function(l,r)
        if l.hu and not r.hu then return true end
        if not l.hu and r.hu then return false end
        if l.hu and r.hu then return l.hu.time < r.hu.time end
        return false
    end)

    return ps[1].chair_id
end

function changpai_table:first_zhuang()
    local max_chair,_ = table.max(self.players,function(_,i) return i end)
    local chair
    repeat
        chair = math.random(1,max_chair)
        local p = self.players[chair]
    until p

    return chair
end

function changpai_table:tile_count_2_tiles(counts,excludes)
    local tiles = {}
    for t,c in pairs(counts) do
        local exclude_c = excludes and excludes[t] or 0
        for _ = 1,c - exclude_c do
            tinsert(tiles,t)
        end
    end

    return tiles
end

function changpai_table:is_play(...)
    return self.cur_state_FSM ~= nil
end

function changpai_table:clear_deposit_and_time_out(player)
    if player.deposit then
        player.deposit = false
        self:broadcast2client("SC_Changpai_Act_Trustee",{chair_id = player.chair_id,is_trustee = player.deposit})
    end
    player.time_out_count = 0
end

function changpai_table:increase_time_out_and_deposit(player)
    player.time_out_count = player.time_out_count or 0
    if player.time_out_count >= 2 then
        player.deposit = true
        player.time_out_count = 0
    end
end

function changpai_table:on_cs_do_action(player,msg)
    self:clear_deposit_and_time_out(player)
    
    local state_actions = {
        [FSM_S.PER_BEGIN] = {

        },
        [FSM_S.XI_PAI] = {

        },
        [FSM_S.WAIT_MO_PAI] = {

        },
        [FSM_S.WAIT_ACTION_AFTER_TIAN_HU] = {
            [ACTION.HU] = self.on_action_after_tianhu,
            [ACTION.PASS] = self.on_action_after_tianhu
        },
        [FSM_S.WAIT_CHU_PAI] = {
            [ACTION.CHU_PAI] = self.on_action_chu_pai
        },
        [FSM_S.WAIT_ACTION_AFTER_FIRSTFIRST_TOU_PAI] = {   --发完牌的第一阶段偷牌
            [ACTION.TOU] = self.on_action_after_first_tou_pai,
            [ACTION.BA_GANG] = self.on_action_after_first_tou_pai,
            [ACTION.PASS] = self.on_action_after_first_tou_pai
        },
        [FSM_S.WAIT_ACTION_AFTER_JIN_PAI] = {   --进张有点像麻将的摸牌
            [ACTION.TOU] = self.on_action_after_mo_pai,
            [ACTION.BA_GANG] = self.on_action_after_mo_pai,
            [ACTION.PASS] = self.on_action_after_mo_pai,
            [ACTION.HU] = self.on_action_after_mo_pai,
            [ACTION.ZI_MO] = self.on_action_after_mo_pai
        },
        [FSM_S.WAIT_ACTION_AFTER_CHU_PAI] = {   --出牌
            [ACTION.PENG] = self.on_action_after_chu_pai,
            [ACTION.HU] = self.on_action_after_chu_pai,
            [ACTION.PASS] = self.on_action_after_chu_pai,
            [ACTION.CHI] = self.on_action_after_chu_pai,
        },
        [FSM_S.WAIT_ACTION_AFTER_FAN_PAI] = {   --翻牌有点像麻将的出牌
            [ACTION.BA_GANG] = self.on_action_after_fan_pai,
            [ACTION.PASS] = self.on_action_after_fan_pai,
            [ACTION.ZI_MO] = self.on_action_after_fan_pai,
            [ACTION.CHI] = self.on_action_after_fan_pai,
            [ACTION.PENG] = self.on_action_after_fan_pai,
            [ACTION.HU] = self.on_action_after_fan_pai,
        },
        [FSM_S.WAIT_QIANG_GANG_HU] = {          --抢巴胡有点像麻将的抢杠胡
            [ACTION.HU] = self.on_action_qiang_gang_hu,
            [ACTION.PASS] = self.on_action_qiang_gang_hu,
            [ACTION.QIANG_GANG_HU] = self.on_action_qiang_gang_hu,
        },
        [FSM_S.FINAL_END] = {

        },
    }

    local fn = state_actions[self.cur_state_FSM] and state_actions[self.cur_state_FSM][msg.action] or nil
    if fn then
        self:lockcall(fn,self,player,msg)
    else
        log.error("unkown state but got action %s fsm %d",msg.action,self.cur_state_FSM)
    end
end

--打牌
function changpai_table:on_cs_act_discard(player, msg)
    if msg and msg.tile and mj_util.check_tile(msg.tile) then
        self:clear_deposit_and_time_out(player)
    end
    self:lockcall(function() self:on_action_chu_pai(player,msg) end)
end


function changpai_table:chu_pai_player()
    return self.players[self.chu_pai_player_index]
end

function changpai_table:broadcast_player_hu(player,action,target,session_id)
    local msg = {
        chair_id = player.chair_id, 
        value_tile = player.hu.tile,
        action = action,
        target_chair_id = target,
        session_id = session_id,
    }

    self:broadcast2client("SC_Changpai_Do_Action",msg)
end

function changpai_table:update_state(new_state)
    self.cur_state_FSM = new_state
    
end

function changpai_table:is_action_time_out()
    local time_out = (os.time() - self.last_action_change_time_stamp) >= def.ACTION_TIME_OUT
    return time_out
end

function changpai_table:next_player_index(from)
    self:done_last_action(self.players[self.chu_pai_player_index])
    local chair = from and from.chair_id or self.chu_pai_player_index
    repeat
        chair = (chair % self.chair_count) + 1
        local p = self.players[chair]
    until p and not p.hu
    self.chu_pai_player_index = chair
   
end

function changpai_table:jump_to_player_index(player)
    local chair_id = type(player) == "number" and player or player.chair_id
    self.chu_pai_player_index = chair_id
    
end

function changpai_table:adjust_shou_pai(player, action, tile,othertile,session_id)
    local shou_pai = player.pai.shou_pai
    local ming_pai = player.pai.ming_pai
    if action == ACTION.BA_GANG then  --巴杠      
        for k,s in pairs(ming_pai) do
            if s.tile == tile and s.type == SECTION_TYPE.PENG then
                local num = 1
                if mj_util.tile_hong(tile)>0 then num =2 end
                tinsert(ming_pai,{
                    type = SECTION_TYPE.BA_GANG,
                    tile = tile,
                    area = TILE_AREA.MING_TILE,
                    whoee = s.whoee,
                    tuos = num,
                    time = timer.nanotime(),
                })
                ming_pai[k] = nil
                table.decr(shou_pai,tile)
                break
            end
        end
    end

    if action == ACTION.PENG then
        table.decr(shou_pai,tile,2)
        local num = 3
        if mj_util.tile_hong(tile)>0 then num =6 end
        tinsert(ming_pai,{
            type = SECTION_TYPE.PENG,
            tile = tile,
            area = TILE_AREA.MING_TILE,
            tuos = num,
            whoee = self.chu_pai_player_index,
        })
    end
    if action == ACTION.TOU then
        table.decr(shou_pai,tile,3)
        local num = 3
        if mj_util.tile_hong(tile)>0 then num =6 end
        tinsert(ming_pai,{
            type = SECTION_TYPE.TOU,
            tile = tile,
            area = TILE_AREA.MING_TILE,
            tuos = num,
            whoee = self.chu_pai_player_index,
        })
    end
    if action == ACTION.CHI then
        table.decr(shou_pai,othertile,1)
        local num = 1
        if mj_util.tile_hong(tile)>0 and mj_util.tile_hong(othertile)>0 then num = 2  end
        if mj_util.tile_hong(tile)==0 and mj_util.tile_hong(othertile)==0 then num = 0 end
        tinsert(ming_pai,{
            type = SECTION_TYPE.CHI,
            tile = tile,
            othertile = othertile,
            tuos = num,
            area = TILE_AREA.MING_TILE,
        })
    end


    self:broadcast2client("SC_Changpai_Do_Action",{chair_id = player.chair_id,value_tile = tile,other_tile = othertile,action = action,session_id = session_id})
end

--掉线，离开，自动胡牌
function changpai_table:auto_act_if_deposit(player,actions)
    
end

function changpai_table:on_chu_pai(tile)
    for _, p in pairs(self.players) do
        if p.chair_id == self.chu_pai_player_index then
            p.chu_pai = tile
            p.chu_pai_count = (p.chu_pai_count or 0) + 1
        else
            p.chu_pai = nil
        end
    end
end
function changpai_table:on_user_fan_pai(tile)
    for _, p in pairs(self.players) do
        if p.chair_id == self.chu_pai_player_index then
            p.fan_pai = tile
           
        else
            p.fan_pai = nil
        end
    end
end
function changpai_table:get_last_chu_pai()
    for _,p in pairs(self.players) do
        if p.chu_pai then
            return p,p.chu_pai
        end
    end
end

function changpai_table:send_data_to_enter_player(player,is_reconnect)
    local msg = {
        state = self.cur_state_FSM,
        round = self.cur_round,
        zhuang = self.zhuang, 
        zhuang_pai = self.zhuang_pai,   
        self_chair_id = player.chair_id,
        act_time_limit = def.ACTION_TIME_OUT,
        decision_time_limit = def.ACTION_TIME_OUT,
        is_reconnect = is_reconnect,
        pb_players = {},
        qie_pai = self.qie_pai
    }

    self:foreach(function(v)
        local tplayer = {}
        tplayer.chair_id = v.chair_id
        if v.pai then
            tplayer.desk_pai = table.values(v.pai.desk_tiles)
            tplayer.pb_ming_pai = table.values(v.pai.ming_pai)
            tplayer.shou_pai = v.chair_id == player.chair_id and 
                self:tile_count_2_tiles(v.pai.shou_pai) or
                table.fill(nil,255,1,table.sum(v.pai.shou_pai))
        end

        if player.chair_id == v.chair_id then
            tplayer.mo_pai =  v.mo_pai
        end
        tplayer.tuos = mj_util.tuos(v.pai,nil,nil,nil)
        tinsert(msg.pb_players,tplayer)
    end)

    -- log.dump(msg,tostring(player.guid))

    local last_chu_pai_player,last_tile = self:get_last_chu_pai()
    if is_reconnect  then
        local total_scores,strtotal_scores = table.map(self.players,function(p,chair) return chair,p.total_score end),{}
        local total_money,strtotal_money = table.map(self.players,function(p,chair) return chair,p.total_money end),{}
        for k,score in pairs(total_scores) do
            strtotal_scores[k] = tostring(score)
        end
        for k,money in pairs(total_money) do
            strtotal_money[k] = tostring(money)
        end
        msg.pb_rec_data = {
            last_chu_pai_chair = last_chu_pai_player and last_chu_pai_player.chair_id or nil,
            last_chu_pai = last_tile,
            total_scores = strtotal_scores, -- table.keys(table.map(self.players,function(p,chair) return chair,p.total_score end)),
            total_money = strtotal_money, -- table.map(self.players,function(p,chair) return chair,p.total_money end)),
        }
        log.dump(msg.pb_rec_data,"is_reconnect_"..tostring(player.guid))
    end

    if self.cur_round and self.cur_round > 0 then
        send2client(player,"SC_Changpai_Desk_Enter",msg)
    end
end

function changpai_table:send_hu_status(player)
    local ps = table.values(self.players)
    table.sort(ps,function(l,r)
        if l.hu and not r.hu then return true end
        if not l.hu and r.hu then return false end
        if l.hu and r.hu then return l.hu.time < r.hu.time end
        return false
    end)

    local status = {}
    table.foreach(ps,function(p,i) 
        tinsert(status,{
            chair_id = p.chair_id,
            hu = p.hu and (p.hu.zi_mo and 2 or 1) or nil,
            hu_index = p.hu and i or nil,
            hu_tile = p.hu and p.hu.tile or nil,
        })
    end)

    send2client(player,"SC_CP_HuStatus",{
        status = status,
    })
end

function changpai_table:reconnect(player)
    log.info("player reconnect : ".. player.chair_id)
    
    self:set_trusteeship(player)
    self:send_data_to_enter_player(player,true)

    if not self:is_play(player) then
        base_table.reconnect(self,player)
        return
    end


    if self.cur_state_FSM == FSM_S.FAST_START_VOTE then
        self:on_reconnect_when_fast_start_vote(player)
        base_table.reconnect(self,player)
        return
    end


    if self.cur_state_FSM == FSM_S.WAIT_CHU_PAI then
        self:on_reconnect_when_chu_pai(player)    
    elseif self.cur_state_FSM == FSM_S.WAIT_ACTION_AFTER_TIAN_HU then
        self:on_reconnect_when_tian_hu(player)
    elseif self.cur_state_FSM == FSM_S.WAIT_ACTION_AFTER_FIRSTFIRST_TOU_PAI then
        self:on_reconnect_when_first_tou_pai(player)
    elseif self.cur_state_FSM == FSM_S.WAIT_ACTION_AFTER_CHU_PAI then
        self:on_reconnect_when_action_after_chu_pai(player)
    elseif self.cur_state_FSM == FSM_S.WAIT_ACTION_AFTER_FAN_PAI then
        self:on_reconnect_when_action_after_fan_pai(player)
    elseif self.cur_state_FSM == FSM_S.WAIT_ACTION_AFTER_JIN_PAI then
        self:on_reconnect_when_action_after_mo_pai(player)
    elseif self.cur_state_FSM == FSM_S.WAIT_QIANG_GANG_HU then
        self:on_reconnect_when_action_qiang_gang_hu(player)    
    end

    self:send_hu_status(player)

    base_table.reconnect(self,player)
end

function changpai_table:begin_clock(timeout,player,total_time)
    if player then
        send2client(player,"SC_TimeOutNotify",{
            left_time = math.ceil(timeout),
            total_time = total_time and math.floor(total_time) or nil,
        })
        return
    end

    self:broadcast2client("SC_TimeOutNotify",{
        left_time = timeout,
        total_time = total_time,
    })
end

function changpai_table:ext_hu(player,mo_pai,qiang_gang)
    local types = {}

    local chu_pai_player = self:chu_pai_player()

    if self.rule.play.tian_di_hu then
        if player.chair_id == self.zhuang and mo_pai and self.mo_pai_count == 1 then
            types[HU_TYPE.TIAN_HU] = 1
        end

        if player.chair_id ~= self.zhuang and player.mo_pai_count <= 1 and player.chu_pai_count == 0 and table.nums(player.pai.ming_pai) == 0 then
            types[HU_TYPE.DI_HU] = 1
        end
    end

    local dgh_dian_pao = self.rule.play.dgh_dian_pao
    local discarder_last_action = chu_pai_player.last_action
    return types
end

function changpai_table:rule_hu_types(pai,in_pai,mo_pai,is_zhuang)
    local private_conf = self:room_private_conf()
    local hu_types = mj_util.hu(pai,in_pai,mo_pai,is_zhuang)
    return table.series(hu_types,function(ones)
        local ts = {}
        for t,c in pairs(ones) do
            ts[t] = c
        end
        return ts
    end)
end

function changpai_table:rule_hu(pai,in_pai,mo_pai,is_zhuang)
    local types = self:rule_hu_types(pai,in_pai,mo_pai,is_zhuang)

    table.sort(types,function(l,r)
        local lscore,lfan = self:calc_types(l)
        local rscore,rfan = self:calc_types(r)
        local curlscore = lscore + 2 ^ lfan
        local currscore = rscore + 2 ^ rfan
        return ( curlscore == currscore ) and (lfan > rfan) or curlscore > currscore
    end)

    return types[1] or {}
end

function changpai_table:hu(player,in_pai,mo_pai,qiang_gang)
    local rule_hu = self:rule_hu(player.pai,in_pai,mo_pai,player.chair_id==self.zhuang)
    return rule_hu
end

function changpai_table:is_hu(pai,in_pai,is_zhuang)
    return mj_util.is_hu(pai,in_pai,is_zhuang)
end

function changpai_table:can_hu(player,in_pai,mo_pai,qiang_gang)
    return self:is_hu(player.pai,in_pai,player.chair_id==self.zhuang)
end

function changpai_table:get_ting_tiles_info(player)
    self:lockcall(function()
        local hu_tips = self.rule and self.rule.play.hu_tips or nil
        if not hu_tips then 
            send2client(player,"SC_ChangpaiGetTingTilesInfo",{
                result = enum.ERROR_OPERATION_INVALID,
            })
            return
        end

        if player.hu then 
            send2client(player,"SC_ChangpaiGetTingTilesInfo",{
                result = enum.ERROR_OPERATION_INVALID,
            })
            return
        end
        
        local ting_tiles = self:ting(player)
        local hu_tile_fans = table.series(ting_tiles or {},function(_,tile)
            return {tile = tile,fan = self:hu_fan(player,tile)} 
        end)

        log.dump(hu_tile_fans)

        send2client(player,"SC_ChangpaiGetTingTilesInfo",{
            tiles_info = hu_tile_fans,
        })
    end)
end

function changpai_table:global_status_info(type)
    if type then
        local n = table.nums(self.players)
	    local min_count = self.start_count or self.room_.min_gamer_count or self.chair_count
        if type == 1 then -- 查询全部桌子
            -- if n < min_count then -- 过滤等待中的桌子
            --     return
            -- end
        elseif type == 2 then -- 查询等待中的桌子
            if n >= min_count then -- 过滤满人的桌子
                return
            end
        end
    end
	
    local seats = {}
    for chair_id,p in pairs(self.players) do
        tinsert(seats,{
            chair_id = chair_id,
            player_info = {
                guid = p.guid,
                icon = p.icon,
                nickname = p.nickname,
                sex = p.sex,
                longitude = p.gps_longitude,
                latitude = p.gps_latitude,
            },
            ready = self.ready_list[chair_id] and true or false,
            online = p.active,
        })
    end
    -- table:info:123456 房间信息
    local private_conf = base_private_table[self.private_id]

    local info = {
        table_id = self.private_id,
        seat_list = seats,
        room_cur_round = self.cur_round or 0,
        rule = self.private_id and json.encode(self.rule) or "",
        game_type = def_first_game_type,
        template_id = private_conf and private_conf.template,
    }

    return info
end
function changpai_table:get_anti_cheat()
    local info = base_table.get_anti_cheat(self)
    return info
end 
return changpai_table
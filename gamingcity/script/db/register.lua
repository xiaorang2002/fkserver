-- 注册消息

local msgopt = require "msgopt"

function get_sd_cash_money_addr()
    
end

require "db.msg.on_login_logout"
require "db.msg.on_bank"
require "db.msg.on_chat_mail"
require "db.msg.on_log"
require "db.msg.on_bonus_hongbao"

local register_dispatcher = msgopt.register

--------------------------------------------------------------------
-- 注册Login发过来的消息分派函数
register_dispatcher("SD_BankTransfer",on_sd_bank_transfer)
register_dispatcher("S_BankTransferByGuid",on_s_bank_transfer_by_guid)
register_dispatcher("SD_LogMoney",on_ld_log_money)
register_dispatcher("LD_AgentAddPlayerMoney",on_LD_AgentAddPlayerMoney)
-- register_dispatcher("LD_QueryMaintain",on_ld_query_maintain)
register_dispatcher("LD_NewNotice",on_ld_NewNotice)
register_dispatcher("LD_DelMessage",on_ld_DelMessage)
register_dispatcher("LD_AlipayEdit",on_ld_AlipayEdit)
register_dispatcher("LD_AgentsTransfer_finish",on_ld_AgentTransfer_finish)
register_dispatcher("LD_CC_ChangeMoney",on_ld_cc_changemoney)
register_dispatcher("LD_DO_SQL",on_ld_do_sql)
register_dispatcher("LD_ReCharge",on_ld_recharge)
register_dispatcher("LD_BankcardEdit",on_ld_BankcardEdit)
--------------------------------------------------------------------
-- 注册Game发过来的消息分派函数
register_dispatcher("SD_Delonline_player",on_sd_delonline_player)
register_dispatcher("SD_OnlineAccount",on_SD_OnlineAccount)
register_dispatcher("S_Logout",on_s_logout)
register_dispatcher("SD_QueryPlayerMsgData",on_sd_query_player_msg)
register_dispatcher("SD_QueryPlayerMarquee",on_sd_query_player_marquee)
register_dispatcher("SD_SetMsgReadFlag",on_sd_Set_Msg_Read_Flag)
register_dispatcher("SD_QueryPlayerData",on_sd_query_player_data)
register_dispatcher("SD_SavePlayerData",on_sd_save_player_data)
register_dispatcher("SD_SavePlayerMoney",on_SD_SavePlayerMoney)
register_dispatcher("SD_SavePlayerBank",on_SD_SavePlayerBank)
register_dispatcher("SD_BankSetPassword",on_sd_bank_set_password)
register_dispatcher("SD_BankChangePassword",on_sd_bank_change_password)
register_dispatcher("SD_ResetPW",on_sd_resetpw)
register_dispatcher("SD_BankLogin",on_sd_bank_login)
-- register_dispatcher("SD_BankTransfer",on_sd_bank_transfer)
register_dispatcher("SD_SaveBankStatement",on_sd_save_bank_statement)
register_dispatcher("SD_BankStatement",on_sd_bank_statement)
register_dispatcher("SD_BankLog",on_SD_BankLog)
register_dispatcher("SD_SendMail",on_sd_send_mail)
register_dispatcher("SD_DelMail",on_sd_del_mail)
register_dispatcher("SD_ReceiveMailAttachment",on_sd_receive_mail_attachment)
-- register_dispatcher("SD_LogMoney",on_sd_log_money)
register_dispatcher("SD_LoadAndroidData",on_sd_load_android_data)
register_dispatcher("SD_CashMoneyType",on_sd_cash_money_type)
register_dispatcher("SD_SavePlayerOxData",on_sd_save_player_Ox_data)
register_dispatcher("SL_Log_Money",on_sl_log_money)
register_dispatcher("SD_QueryOxConfigData",on_sd_query_Ox_config_data)
register_dispatcher("SL_Log_Game",on_sl_log_Game)
register_dispatcher("SL_Channel_Invite_Tax",on_sl_channel_invite_tax)
register_dispatcher("SD_QueryPlayerInviteReward",on_sd_query_player_invite_reward)
register_dispatcher("SD_QueryChannelInviteCfg",on_sd_query_channel_invite_cfg)
register_dispatcher("SL_Log_Robot_Money",on_sl_robot_log_money)
register_dispatcher("SD_ReCharge",on_sd_recharge)
register_dispatcher("SD_CheckCashTime",on_sd_check_cashTime)
register_dispatcher("SD_ProxyCashToBank",on_sd_proxy_cash_to_bank)
register_dispatcher("LS_CC_ChangeMoney",on_sd_agent_transfer_success)
register_dispatcher("SD_WithDrawCash",on_SD_WithDrawCash)
register_dispatcher("SD_ChangeBank",on_change_bank)
register_dispatcher("SD_BankLog_New",on_banklog_new)
register_dispatcher("SD_CheckBankTransferEnable",on_SD_CheckBankTransferEnable)
register_dispatcher("SD_PlayerBankTransfer",on_SD_PlayerBankTransfer)
register_dispatcher("SD_ValidateboxFengIp",on_SD_ValidateboxFengIp)
register_dispatcher("SD_GetBonusPoolMoney",on_SD_GetBonusPoolMoney)
register_dispatcher("SD_UpdateBonusPool",on_SD_UpdateBonusPool)
register_dispatcher("SD_SaveCollapseLog",on_SD_SaveCollapsePlayerLog)
register_dispatcher("SD_LogProxyCostPlayerMoney",on_SD_LogProxyCostPlayerMoney)
register_dispatcher("SD_Get_Instructor_Weixin",on_SD_Get_Instructor_Weixin)
--下注流水
register_dispatcher("SD_LogBetFlow",on_sd_log_bet_flow)
--红包活动
register_dispatcher("SD_ReqPlayerBonusGameStatistics",on_sd_query_player_bonus_game_statistics)
register_dispatcher("SD_ReqQueryBonusActivity",on_sd_query_active_bonus_hongbao_activity)
register_dispatcher("SD_ReqCreatePlayerBonus",on_sd_create_bonus_hongbao)
register_dispatcher("SD_ReqPickPlayerBonus",on_sd_pick_bonus_hongbao)
register_dispatcher("SD_ReqQueryPlayerBonus",on_sd_query_bonus_hongbao)
register_dispatcher("SD_QueryPlayerCurrentBonusLimitInfo",on_sd_query_bonus_activity_limit_info)
register_dispatcher("SD_UpdatePlayerCurrentBonusLimitInfo",on_sd_update_bonus_activity_limit_info)




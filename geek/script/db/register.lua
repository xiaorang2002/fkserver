-- 注册消息

local msgopt = require "msgopt"

function get_sd_cash_money_addr()
    
end

require "db.msg.on_login_logout"
require "db.msg.on_bank"
require "db.msg.on_chat_mail"
require "db.msg.on_log"
require "db.msg.on_bonus_hongbao"
require "db.msg.on_club"
require "db.msg.on_notice"

local register_dispatcher = msgopt.register

--------------------------------------------------------------------
-- 注册Login发过来的消息分派函数
register_dispatcher("SD_BankTransfer",on_sd_bank_transfer)
register_dispatcher("S_BankTransferByGuid",on_s_bank_transfer_by_guid)
register_dispatcher("LD_NewNotice",on_ld_NewNotice)
register_dispatcher("LD_DelMessage",on_ld_DelMessage)
register_dispatcher("LD_AlipayEdit",on_ld_AlipayEdit)
register_dispatcher("LD_BankcardEdit",on_ld_BankcardEdit)
register_dispatcher("LD_VerifyAccount",on_ld_verify_account)
register_dispatcher("LD_RegAccount",on_ld_reg_account)
register_dispatcher("LD_PhoneQuery",on_ld_phone_query)
register_dispatcher("LD_LogLogin",on_ld_log_login)
register_dispatcher("SD_LogLogout",on_sd_log_logout)
register_dispatcher("SD_SetNickname",on_sd_set_nickname)
register_dispatcher("SD_BankSetPassword",on_sd_set_nickname)
--------------------------------------------------------------------
-- 注册Game发过来的消息分派函数
register_dispatcher("S_Logout",on_s_logout)
register_dispatcher("SD_QueryPlayerMsgData",on_sd_query_player_msg)
register_dispatcher("SD_QueryPlayerMarquee",on_sd_query_player_marquee)
register_dispatcher("SD_SetMsgReadFlag",on_sd_Set_Msg_Read_Flag)
register_dispatcher("SD_SavePlayerMoney",on_SD_SavePlayerMoney)
register_dispatcher("SD_SavePlayerBank",on_SD_SavePlayerBank)
register_dispatcher("SD_BankChangePassword",on_sd_bank_change_password)
register_dispatcher("SD_ResetPW",on_sd_resetpw)
register_dispatcher("SD_BankLogin",on_sd_bank_login)
register_dispatcher("SD_SaveBankStatement",on_sd_save_bank_statement)
register_dispatcher("SD_BankStatement",on_sd_bank_statement)
register_dispatcher("SD_BankLog",on_SD_BankLog)
register_dispatcher("SD_SendMail",on_sd_send_mail)
register_dispatcher("SD_DelMail",on_sd_del_mail)
register_dispatcher("SD_ReceiveMailAttachment",on_sd_receive_mail_attachment)
register_dispatcher("SD_LogMoney",on_sd_log_money)
register_dispatcher("SD_LoadAndroidData",on_sd_load_android_data)
register_dispatcher("SD_CashMoneyType",on_sd_cash_money_type)
register_dispatcher("SD_SavePlayerOxData",on_sd_save_player_Ox_data)
register_dispatcher("SD_LogGameMoney",on_sd_log_game_money)
register_dispatcher("SD_QueryOxConfigData",on_sd_query_Ox_config_data)
register_dispatcher("SL_Log_Game",on_sl_log_game)
register_dispatcher("SL_Channel_Invite_Tax",on_sl_channel_invite_tax)
register_dispatcher("SD_QueryPlayerInviteReward",on_sd_query_player_invite_reward)
register_dispatcher("SD_QueryChannelInviteCfg",on_sd_query_channel_invite_cfg)
register_dispatcher("SL_Log_Robot_Money",on_sl_robot_log_money)
register_dispatcher("SD_LogClubCommission",on_sd_log_club_commission)
register_dispatcher("SD_LogClubCommissionContributuion",on_sd_log_club_commission_contribution)
register_dispatcher("SD_CheckCashTime",on_sd_check_cashTime)
register_dispatcher("SD_ProxyCashToBank",on_sd_proxy_cash_to_bank)
register_dispatcher("SD_BankLog_New",on_banklog_new)
register_dispatcher("SD_CheckBankTransferEnable",on_SD_CheckBankTransferEnable)
register_dispatcher("SD_UpdateBonusPool",on_SD_UpdateBonusPool)
register_dispatcher("SD_SaveCollapseLog",on_SD_SaveCollapsePlayerLog)
register_dispatcher("SD_LogProxyCostPlayerMoney",on_SD_LogProxyCostPlayerMoney)
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

register_dispatcher("SD_LogRecharge",on_sd_log_recharge)

register_dispatcher("SD_CreateClub",on_sd_create_club)
register_dispatcher("SD_DismissClub",on_sd_dismiss_club)
register_dispatcher("SD_DelClub",on_sd_del_club)
register_dispatcher("SD_JoinClub",on_sd_join_club)
register_dispatcher("SD_ExitClub",on_sd_exit_club)
register_dispatcher("SD_ChangePlayerMoney",on_sd_change_player_money)
register_dispatcher("SD_ChangeClubMoney",on_sd_change_club_money)
register_dispatcher("SD_NewMoneyType",on_sd_new_money_type)
register_dispatcher("SD_AddClubMember",on_sd_add_club_member)
register_dispatcher("SD_CreateClubTemplate",on_sd_create_club_template)
register_dispatcher("SD_RemoveClubTemplate",on_sd_remove_club_template)
register_dispatcher("SD_EditClubTemplate",on_sd_edit_club_template)
register_dispatcher("SD_BatchJoinClub",on_sd_batch_join_club)
register_dispatcher("SD_TransferMoney",on_sd_transfer_money)
register_dispatcher("SD_BindPhone",on_sd_bind_phone)
register_dispatcher("SD_RequestShareParam",on_sd_request_share_param)
register_dispatcher("SD_LogPlayerCommission",on_sd_log_player_commission)
register_dispatcher("SD_CreatePartner",on_sd_create_partner)
register_dispatcher("SD_DismissPartner",on_sd_dismiss_partner)
register_dispatcher("SD_JoinPartner",on_sd_join_partner)
register_dispatcher("SD_ExitPartner",on_sd_exit_partner)
register_dispatcher("SD_LogPlayerCommissionContributes",on_sd_log_player_commission_contributes)
register_dispatcher("SD_UpdatePlayerInfo",on_sd_update_player_info)
register_dispatcher("SD_LogExtGameRound",on_sd_log_ext_game_round)
register_dispatcher("SD_EditClubInfo",on_sd_edit_club_info)
register_dispatcher("SD_QueryPlayerStatistics",on_sd_query_player_statistics)
register_dispatcher("SD_LogClubActionMsg",on_sd_log_club_action_msg)
register_dispatcher("SD_SetClubRole",on_sd_set_club_role)
register_dispatcher("SD_AddIntoClubGamingBlacklist",on_sd_add_into_club_gaming_blacklist)
register_dispatcher("SD_RemoveFromClubGamingBlacklist",on_sd_remove_from_club_gaming_blacklist)
register_dispatcher("SD_AddNotice",on_sd_add_notice)
register_dispatcher("SD_EditNotice",on_sd_edit_notice)
register_dispatcher("SD_RemoveNotice",on_sd_del_notice)

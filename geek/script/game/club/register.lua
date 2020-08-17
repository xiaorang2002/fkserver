require "game.club.on_club"
require "game.club.on_template"

--俱乐部
register_dispatcher("C2S_CLUBLIST_REQ",on_cs_club_list)
register_dispatcher("C2S_CREATE_CLUB_REQ",on_cs_club_create)
register_dispatcher("C2S_CLUB_DISMISS_REQ",on_cs_club_dismiss)
register_dispatcher("C2S_JOIN_CLUB_REQ",on_cs_club_join_req)
register_dispatcher("C2S_CLUB_KICK_PLAYER_REQ",on_cs_club_kickout)
register_dispatcher("C2S_CLUB_INFO_REQ",on_cs_club_detail_info_req)
register_dispatcher("C2S_CLUB_PLAYER_LIST_REQ",on_cs_club_query_memeber)
register_dispatcher("C2S_CLUB_OP_REQ",on_cs_club_operation)
register_dispatcher("C2S_CLUB_REQUEST_LIST_REQ",on_cs_club_request_list_req)
register_dispatcher("C2S_EDIT_CLUB_GAME_TYPE_REQ",on_cs_club_edit_game_type)
register_dispatcher("C2S_CREATE_CLUB_WITH_INVITE_MAIL",on_cs_club_create_club_with_mail)
register_dispatcher("C2S_INVITE_JOIN_CLUB",on_cs_club_invite_join_club)

register_dispatcher("C2S_CLUB_TEAM_LIST_REQ",on_cs_club_team_list)
register_dispatcher("C2S_CLUB_TRANSFER_MONEY_REQ",on_cs_transfer_money)

register_dispatcher("C2S_CONFIG_CLUB_TEMPLATE_COMMISSION",on_cs_config_club_template_commission)
register_dispatcher("C2S_GET_CLUB_TEMPLATE_COMMISSION",on_cs_get_club_template_commission)
register_dispatcher("C2S_CONFIG_CLUB_TEAM_TEMPLATE",on_cs_config_club_team_template)
register_dispatcher("C2S_GET_CLUB_TEAM_TEMPLATE_CONFIG",on_cs_get_club_team_template_conf)

register_dispatcher("C2S_EXCHANGE_CLUB_COMMISSON_REQ",on_cs_exchagne_club_commission)

register_dispatcher("C2S_CLUB_MONEY_REQ",on_cs_club_money)

register_dispatcher("B2S_CLUB_CREATE",on_bs_club_create)

register_dispatcher("C2S_CONFIG_FAST_GAME_LIST",on_cs_config_fast_game_list)

register_dispatcher("B2S_CLUB_CREATE_WITH_GROUP",on_bs_club_create_with_group)

register_dispatcher("C2S_IMPORT_PLAYER_FROM_GROUP",on_cs_club_import_player_from_group)

register_dispatcher("C2S_CLUB_FORCE_DISMISS_TABLE",on_cs_force_dismiss_table)

register_dispatcher("C2S_CLUB_BLOCK_PULL_GROUPS",on_cs_pull_block_groups)
register_dispatcher("C2S_CLUB_BLOCK_NEW_GROUP",on_cs_new_block_group)
register_dispatcher("C2S_CLUB_BLOCK_DEL_GROUP",on_cs_del_block_group)
register_dispatcher("C2S_CLUB_BLOCK_ADD_PLAYER_TO_GROUP",on_cs_add_player_to_block_group)
register_dispatcher("C2S_CLUB_BLOCK_REMOVE_PLAYER_FROM_GROUP",on_cs_remove_player_from_block_group)

register_dispatcher("C2S_CLUB_EDIT_INFO",on_cs_club_edit_info)
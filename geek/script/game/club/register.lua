require "game.club.on_club"

--俱乐部
register_dispatcher("C2S_CLUBLIST_REQ",on_cs_club_list)
register_dispatcher("C2S_CREATE_CLUB_REQ",on_cs_club_create)
register_dispatcher("C2S_CLUB_DISMISS_REQ",on_cs_club_dismiss)
register_dispatcher("C2S_JOIN_CLUB_REQ",on_cs_club_join_req)
register_dispatcher("C2S_CLUB_KICK_PLAYER_REQ",on_cs_club_kickout)
register_dispatcher("C2S_CLUB_INVITE_REQ",on_cs_club_invite_join_req)
register_dispatcher("C2S_CLUB_INFO_REQ",on_cs_club_detail_info_req)
register_dispatcher("C2S_CLUB_PLAYER_LIST_REQ",on_cs_club_query_memeber)
register_dispatcher("C2S_CLUB_OP_REQ",on_cs_club_operation)
register_dispatcher("C2S_CLUB_REQUEST_LIST_REQ",on_cs_club_request_list_req)
register_dispatcher("C2S_EDIT_CLUB_GAME_TYPE_REQ",on_cs_club_edit_game_type)
register_dispatcher("C2S_CREATE_CLUB_WITH_REQ",on_cs_club_create_club_with_req)
register_dispatcher("C2S_INVITE_JOIN_CLUB",on_cs_club_invite_join_club)
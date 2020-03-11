local pb = require "pb_files"


local enums = {
    ITEM_PRICE_TYPE_GOLD = pb.enum("ITEM_PRICE_TYPE","ITEM_PRICE_TYPE_GOLD"),
    ITEM_PRICE_TYPE_DIAMOND = pb.enum("ITEM_PRICE_TYPE","ITEM_PRICE_TYPE_DIAMOND"),
    ITEM_PRICE_TYPE_ROOM_CARD = pb.enum("ITEM_PRICE_TYPE","ITEM_PRICE_TYPE_ROOM_CARD"),

    MONEY_TYPE_GOLD = pb.enum("MONEY_TYPE","MONEY_TYPE_GOLD"),
    MONEY_TYPE_ROOM_CARD = pb.enum("MONEY_TYPE","MONEY_TYPE_ROOM_CARD"),
    MONEY_TYPE_DIAMOND = pb.enum("MONEY_TYPE","MONEY_TYPE_DIAMOND"),

    PAY_OPTION_AA = pb.enum("PAY_OPTION","AA"),
    PAY_OPTION_BOSS = pb.enum("PAY_OPTION","BOSS"),
    PAY_OPTION_ROOM_OWNER = pb.enum("PAY_OPTION","ROOM_OWNER"),

    BANK_STATEMENT_OPT_TYPE_DEPOSIT = pb.enum("BANK_STATEMENT_OPT_TYPE","BANK_STATEMENT_OPT_TYPE_DEPOSIT"),
    BANK_STATEMENT_OPT_TYPE_DRAW = pb.enum("BANK_STATEMENT_OPT_TYPE","BANK_STATEMENT_OPT_TYPE_DRAW"),
    BANK_STATEMENT_OPT_TYPE_TRANSFER_OUT = pb.enum("BANK_STATEMENT_OPT_TYPE","BANK_STATEMENT_OPT_TYPE_TRANSFER_OUT"),
    BANK_STATEMENT_OPT_TYPE_TRANSFER_IN = pb.enum("BANK_STATEMENT_OPT_TYPE","BANK_STATEMENT_OPT_TYPE_TRANSFER_IN"),
    BANK_STATEMENT_OPT_TYPE_REWARD_LOGIN = pb.enum("BANK_STATEMENT_OPT_TYPE","BANK_STATEMENT_OPT_TYPE_REWARD_LOGIN"),
    BANK_STATEMENT_OPT_TYPE_REWARD_ONLINE = pb.enum("BANK_STATEMENT_OPT_TYPE","BANK_STATEMENT_OPT_TYPE_REWARD_ONLINE"),
    BANK_STATEMENT_OPT_TYPE_RELIEF_PAYMENT = pb.enum("BANK_STATEMENT_OPT_TYPE","BANK_STATEMENT_OPT_TYPE_RELIEF_PAYMENT"),

    BANK_OPT_RESULT_SUCCESS = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_SUCCESS"),
    BANK_OPT_RESULT_PASSWORD_HAS_BEEN_SET = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_PASSWORD_HAS_BEEN_SET"),
    BANK_OPT_RESULT_PASSWORD_IS_NOT_SET = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_PASSWORD_IS_NOT_SET"),
    BANK_OPT_RESULT_OLD_PASSWORD_ERR = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_OLD_PASSWORD_ERR"),
    BANK_OPT_RESULT_ALREADY_LOGGED = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_ALREADY_LOGGED"),
    BANK_OPT_RESULT_LOGIN_FAILED = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_LOGIN_FAILED"),
    BANK_OPT_RESULT_NOT_LOGIN = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_NOT_LOGIN"),
    BANK_OPT_RESULT_MONEY_ERR = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_MONEY_ERR"),
    BANK_OPT_RESULT_TRANSFER_ACCOUNT = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_TRANSFER_ACCOUNT"),
    BANK_OPT_RESULT_FORBID_IN_GAMEING = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_FORBID_IN_GAMEING"),
    BANK_OPT_RESULT_BANK_MAINTAIN = pb.enum("BANK_OPT_RESULT","BANK_OPT_RESULT_BANK_MAINTAIN"),

    GAME_READY_MODE_NONE = pb.enum("GAME_READY_MODE","GAME_READY_MODE_NONE"),
    GAME_READY_MODE_ALL = pb.enum("GAME_READY_MODE","GAME_READY_MODE_ALL"),
    GAME_READY_MODE_PART = pb.enum("GAME_READY_MODE","GAME_READY_MODE_PART"),

    GAME_BAND_ALIPAY_SUCCESS = pb.enum("GAME_BAND_ALIPAY","GAME_BAND_ALIPAY_SUCCESS"),
    GAME_BAND_ALIPAY_CHECK_ERROR = pb.enum("GAME_BAND_ALIPAY","GAME_BAND_ALIPAY_CHECK_ERROR"),
    GAME_BAND_ALIPAY_REPEAT_BAND = pb.enum("GAME_BAND_ALIPAY","GAME_BAND_ALIPAY_REPEAT_BAND"),
    GAME_BAND_ALIPAY_DB_ERROR = pb.enum("GAME_BAND_ALIPAY","GAME_BAND_ALIPAY_DB_ERROR"),

    GM_ANDROID_ADD_ACTIVE = pb.enum("GM_ANDROID_OPT","GM_ANDROID_ADD_ACTIVE"),


    GAME_SERVER_RESULT_SUCCESS = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_SUCCESS"),
    GAME_SERVER_RESULT_IN_GAME = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_IN_GAME"),
    GAME_SERVER_RESULT_IN_ROOM = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_IN_ROOM"),
    GAME_SERVER_RESULT_OUT_ROOM = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_OUT_ROOM"),
    GAME_SERVER_RESULT_NOT_FIND_ROOM = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_NOT_FIND_ROOM"),
    GAME_SERVER_RESULT_NOT_FIND_TABLE = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_NOT_FIND_TABLE"),
    GAME_SERVER_RESULT_NOT_FIND_CHAIR = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_NOT_FIND_CHAIR"),
    GAME_SERVER_RESULT_PLAYER_ON_CHAIR = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_PLAYER_ON_CHAIR"),
    GAME_SERVER_RESULT_CHAIR_HAVE_PLAYER = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_CHAIR_HAVE_PLAYER"),
    GAME_SERVER_RESULT_PLAYER_NO_CHAIR = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_PLAYER_NO_CHAIR"),
    GAME_SERVER_RESULT_OHTER_ON_CHAIR = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_OHTER_ON_CHAIR"),
    GAME_SERVER_RESULT_NO_GAME_SERVER = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_NO_GAME_SERVER"),
    GAME_SERVER_RESULT_ROOM_LIMIT = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_ROOM_LIMIT"),
    GAME_SERVER_RESULT_FREEZEACCOUNT = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_FREEZEACCOUNT"),
    GAME_SERVER_RESULT_MAINTAIN = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_MAINTAIN"),
    GAME_SERVER_RESULT_CREATE_PRIVATE_ROOM_CHAIR = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_CREATE_PRIVATE_ROOM_CHAIR"),
    GAME_SERVER_RESULT_CREATE_PRIVATE_ROOM_ALL = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_CREATE_PRIVATE_ROOM_ALL"),
    GAME_SERVER_RESULT_CREATE_PRIVATE_ROOM_BANK = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_CREATE_PRIVATE_ROOM_BANK"),
    GAME_SERVER_RESULT_CREATE_PRIVATE_ROOM_MONEY = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_CREATE_PRIVATE_ROOM_MONEY"),
    GAME_SERVER_RESULT_JOIN_PRIVATE_ROOM_ALL = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_JOIN_PRIVATE_ROOM_ALL"),
    GAME_SERVER_RESULT_JOIN_PRIVATE_ROOM_BANK = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_JOIN_PRIVATE_ROOM_BANK"),
    GAME_SERVER_RESULT_JOIN_PRIVATE_ROOM_MONEY = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_JOIN_PRIVATE_ROOM_MONEY"),
    GAME_SERVER_RESULT_PRIVATE_ROOM_NOT_FOUND = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_PRIVATE_ROOM_NOT_FOUND"),
    GAME_SERVER_RESULT_PRIVATE_ROOM_NO_FREE_CHAIR = pb.enum("GAME_SERVER_RESULT","GAME_SERVER_RESULT_PRIVATE_ROOM_NO_FREE_CHAIR"),

    LOGIN_RESULT_SUCCESS = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SUCCESS"),
    LOGIN_RESULT_REPEAT_LOGIN = pb.enum("LOGIN_RESULT","LOGIN_RESULT_REPEAT_LOGIN"),
    LOGIN_RESULT_DB_ERR = pb.enum("LOGIN_RESULT","LOGIN_RESULT_DB_ERR"),
    LOGIN_RESULT_ACCOUNT_PASSWORD_ERR = pb.enum("LOGIN_RESULT","LOGIN_RESULT_ACCOUNT_PASSWORD_ERR"),
    LOGIN_RESULT_NO_DEFAULT_LOBBY = pb.enum("LOGIN_RESULT","LOGIN_RESULT_NO_DEFAULT_LOBBY"),
    LOGIN_RESULT_SMS_CLOSED = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SMS_CLOSED"),
    LOGIN_RESULT_SMS_REPEATED = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SMS_REPEATED"),
    LOGIN_RESULT_RESET_ACCOUNT_FAILED = pb.enum("LOGIN_RESULT","LOGIN_RESULT_RESET_ACCOUNT_FAILED"),
    LOGIN_RESULT_SMS_FAILED = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SMS_FAILED"),
    LOGIN_RESULT_ALIYUN_FAILED = pb.enum("LOGIN_RESULT","LOGIN_RESULT_ALIYUN_FAILED"),
    LOGIN_RESULT_SET_PASSWORD_FAILED  = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SET_PASSWORD_FAILED"),
    LOGIN_RESULT_SET_NICKNAME_FAILED = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SET_NICKNAME_FAILED"),
    LOGIN_RESULT_SET_PASSWORD_GUEST = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SET_PASSWORD_GUEST"),
    LOGIN_RESULT_SAME_PASSWORD = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SAME_PASSWORD"),
    LOGIN_RESULT_LOGIN_VALIDATEBOX_FAIL = pb.enum("LOGIN_RESULT","LOGIN_RESULT_LOGIN_VALIDATEBOX_FAIL"),
    LOGIN_RESULT_ACCOUNT_DISABLED = pb.enum("LOGIN_RESULT","LOGIN_RESULT_ACCOUNT_DISABLED"),
    LOGIN_RESULT_RESET_ACCOUNT_DUP_ACC = pb.enum("LOGIN_RESULT","LOGIN_RESULT_RESET_ACCOUNT_DUP_ACC"),
    LOGIN_RESULT_RESET_ACCOUNT_DUP_NICKNAME = pb.enum("LOGIN_RESULT","LOGIN_RESULT_RESET_ACCOUNT_DUP_NICKNAME"),
    LOGIN_RESULT_SET_NICKNAME_DUP_NICKNAME = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SET_NICKNAME_DUP_NICKNAME"),
    LOGIN_RESULT_SET_ACCOUNT_OR_PASSWORD_EMPTY = pb.enum("LOGIN_RESULT","LOGIN_RESULT_SET_ACCOUNT_OR_PASSWORD_EMPTY"),
    LOGIN_RESULT_NICKNAME_EMPTY = pb.enum("LOGIN_RESULT","LOGIN_RESULT_NICKNAME_EMPTY"),
    LOGIN_RESULT_TEL_LEN_ERR = pb.enum("LOGIN_RESULT","LOGIN_RESULT_TEL_LEN_ERR"),
    LOGIN_RESULT_TEL_ERR = pb.enum("LOGIN_RESULT","LOGIN_RESULT_TEL_ERR"),
    LOGIN_RESULT_NICKNAME_LIMIT = pb.enum("LOGIN_RESULT","LOGIN_RESULT_NICKNAME_LIMIT"),
    LOGIN_RESULT_POTATO_CHECK_ERROR = pb.enum("LOGIN_RESULT","LOGIN_RESULT_POTATO_CHECK_ERROR"),
    LOGIN_RESULT_ACCOUNT_SIZE_LIMIT = pb.enum("LOGIN_RESULT","LOGIN_RESULT_ACCOUNT_SIZE_LIMIT"),
    LOGIN_RESULT_ACCOUNT_CHAR_LIMIT = pb.enum("LOGIN_RESULT","LOGIN_RESULT_ACCOUNT_CHAR_LIMIT"),
    LOGIN_RESULT_LOGIN_QUQUE = pb.enum("LOGIN_RESULT","LOGIN_RESULT_LOGIN_QUQUE"),
    LOGIN_RESULT_AUTH_CHECK_ERROR = pb.enum("LOGIN_RESULT","LOGIN_RESULT_AUTH_CHECK_ERROR"),

    REG_ACCOUNT_RESULT_SUCCESS = pb.enum("LOGIN_RESULT","REG_ACCOUNT_RESULT_SUCCESS"),

    LOG_MONEY_OPT_TYPE_MAAJAN = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_MAAJAN"),
    LOG_MONEY_OPT_TYPE_BUY_ITEM = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BUY_ITEM"),
    LOG_MONEY_OPT_TYPE_BOX = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BOX"),
    LOG_MONEY_OPT_TYPE_REWARD_LOGIN = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_REWARD_LOGIN"),
    LOG_MONEY_OPT_TYPE_REWARD_ONLINE = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_REWARD_ONLINE"),
    LOG_MONEY_OPT_TYPE_RELIEF_PAYMENT = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_RELIEF_PAYMENT"),
    LOG_MONEY_OPT_TYPE_LAND = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_LAND"),
    LOG_MONEY_OPT_TYPE_ZHAJINHUA = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_ZHAJINHUA"),
    LOG_MONEY_OPT_TYPE_SHOWHAND = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_SHOWHAND"),
    LOG_MONEY_OPT_TYPE_OX = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_OX"),
    LOG_MONEY_OPT_TYPE_FURIT = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_FURIT"),
    LOG_MONEY_OPT_TYPE_BENZ_BMW = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BENZ_BMW"),
    LOG_MONEY_OPT_TYPE_TEXAS = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_TEXAS"),
    LOG_MONEY_OPT_TYPE_BUYU = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BUYU"),
    LOG_MONEY_OPT_TYPE_SLOTMA = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_SLOTMA"),
    LOG_MONEY_OPT_TYPE_RESET_ACCOUNT = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_RESET_ACCOUNT"),
    LOG_MONEY_OPT_TYPE_CASH_MONEY = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_CASH_MONEY"),
    LOG_MONEY_OPT_TYPE_RECHARGE_MONEY = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_RECHARGE_MONEY"),
    LOG_MONEY_OPT_TYPE_GM = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_GM"),
    LOG_MONEY_OPT_TYPE_INVITE = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_INVITE"),
    LOG_MONEY_OPT_TYPE_CASH_MONEY_FALSE = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_CASH_MONEY_FALSE"),
    LOG_MONEY_OPT_TYPE_CREATE_PRIVATE_ROOM  = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_CREATE_PRIVATE_ROOM"),
    LOG_MONEY_OPT_TYPE_BANKER_OX  = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BANKER_OX"),
    LOG_MONEY_OPT_TYPE_CLASSICS_OX = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_CLASSICS_OX"),
    LOG_MONEY_OPT_TYPE_THIRTEEN_WATER = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_THIRTEEN_WATER"),
    LOG_MONEY_OPT_TYPE_AGENTTOAGENT_MONEY = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_AGENTTOAGENT_MONEY"),
    LOG_MONEY_OPT_TYPE_AGENTTOPLAYER_MONEY = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_AGENTTOPLAYER_MONEY"),
    LOG_MONEY_OPT_TYPE_PLAYERTOAGENT_MONEY = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_PLAYERTOAGENT_MONEY"),
    LOG_MONEY_OPT_TYPE_AGENTBANKTOPLAYER_MONEY = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_AGENTBANKTOPLAYER_MONEY"),
    LOG_MONEY_OPT_TYPE_BANKDRAW = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BANKDRAW"),
    LOG_MONEY_OPT_TYPE_BANKDEPOSIT = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BANKDEPOSIT"),
    LOG_MONEY_OPT_TYPE_BANKDRAWBACK = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BANKDRAWBACK"),
    LOG_MONEY_OPT_TYPE_BANKTRANSFER = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BANKTRANSFER"),
    LOG_MONEY_OPT_TYPE_REDBLACK = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_REDBLACK"),
    LOG_MONEY_OPT_TYPE_SANGONG = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_SANGONG"),
    LOG_MONEY_OPT_TYPE_BIGTWO = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BIGTWO"),
    LOG_MONEY_OPT_TYPE_BACCARAT = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BACCARAT"),
    LOG_MONEY_OPT_TYPE_SAVE_BACK = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_SAVE_BACK"),
    LOG_MONEY_OPT_TYPE_TWENTY_ONE = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_TWENTY_ONE"),
    LOG_MONEY_OPT_TYPE_SHAIBAO = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_SHAIBAO"),
    LOG_MONEY_OPT_TYPE_FIVESTAR = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_FIVESTAR"),
    LOG_MONEY_OPT_TYPE_TORADORA = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_TORADORA"),
    LOG_MONEY_OPT_TYPE_REDBLACK_PRIZEPOOL = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_REDBLACK_PRIZEPOOL"),
    LOG_MONEY_OPT_TYPE_BONUS_HONGBAO = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_BONUS_HONGBAO"),
    LOG_MONEY_OPT_TYPE_SHAIBAO_PRIZEPOOL = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_SHAIBAO_PRIZEPOOL"),
    LOG_MONEY_OPT_TYPE_SHELONGMEN = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_SHELONGMEN"),
    LOG_MONEY_OPT_TYPE_PROXY_CASH_MONEY = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_PROXY_CASH_MONEY"),
    LOG_MOENY_OPT_TYPE_MAAJAN_CUSTOMIZE = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MOENY_OPT_TYPE_MAAJAN_CUSTOMIZE"),
    LOG_MONEY_OPT_TYPE_CASH_MONEY_IN_CLUB = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_CASH_MONEY_IN_CLUB"),
    LOG_MONEY_OPT_TYPE_RECHAGE_MONEY_IN_CLUB = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_RECHAGE_MONEY_IN_CLUB"),
    LOG_MONEY_OPT_TYPE_ROOM_FEE = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_ROOM_FEE"),
    LOG_MONEY_OPT_TYPE_CLUB_COMMISSION = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_CLUB_COMMISSION"),
    LOG_MONEY_OPT_TYPE_GAME_TAX = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_GAME_TAX"),
    LOG_MONEY_OPT_TYPE_INIT_GIFT = pb.enum("LOG_MONEY_OPT_TYPE","LOG_MONEY_OPT_TYPE_INIT_GIFT"),
    

    SYNC_ADD = pb.enum("SYNC_TYPE","SYNC_ADD"),
    SYNC_DEL = pb.enum("SYNC_TYPE","SYNC_DEL"),
    SYNC_UPDATE = pb.enum("SYNC_TYPE","SYNC_UPDATE"),

    OPERATION_ADD = pb.enum("OPERATION_TYPE","ADD"),
    OPERATION_DEL = pb.enum("OPERATION_TYPE","DEL"),
    OPERATION_MODIFY = pb.enum("OPERATION_TYPE","MODIFY"),

    ERROR_NONE = pb.enum("ERROR_CODE","ERROR_NONE"),
    ERROR_CLUB_OVERFLOW_MAX = pb.enum("ERROR_CODE","ERROR_CLUB_OVERFLOW_MAX"),
    ERROR_CLUB_UNKOWN = pb.enum("ERROR_CODE","ERROR_CLUB_UNKONW"),
    ERROR_CLUB_NOT_FOUND = pb.enum("ERROR_CODE","ERROR_CLUB_NOT_FOUND"),
    ERROR_NOT_IS_CLUB_MEMBER = pb.enum("ERROR_CODE","ERROR_NOT_IS_CLUB_MEMBER"),
    ERROR_NOT_IS_CLUB_BOSS = pb.enum("ERROR_CODE","ERROR_NOT_IS_CLUB_BOSS"),
    ERROR_NOT_SET_ADMIN = pb.enum("ERROR_CODE","ERROR_NOT_SET_ADMIN"),
    ERROR_CLUB_ADMIN_MAX = pb.enum("ERROR_CODE","ERROR_CLUB_ADMIN_MAX"),
    ERROR_CLUB_PLAYER_MAX = pb.enum("ERROR_CODE","ERROR_CLUB_PLAYER_MAX"),
    ERROR_NOT_REMOVE_ADMIN_OR_BOSS = pb.enum("ERROR_CODE","ERROR_NOT_REMOVE_ADMIN_OR_BOSS"),
    ERROR_CLUB_UNLOCK_CRT = pb.enum("ERROR_CODE","ERROR_CLUB_UNLOCK_CRT"),
    ERROR_JOIN_ROOM_NO = pb.enum("ERROR_CODE","ERROR_JOIN_ROOM_NO"),
    ERROR_JOIN_ROOM_EXCESS = pb.enum("ERROR_CODE","ERROR_JOIN_ROOM_EXCESS"),
    ERROR_JOIN_ROOM_NO_JOIN = pb.enum("ERROR_CODE","ERROR_JOIN_ROOM_NO_JOIN"),
    ERROR_CLUB_OP_EXPIRE = pb.enum("ERROR_CODE","ERROR_CLUB_OP_EXPIRE"),
    ERROR_CLUB_OP_JOIN_CHECK = pb.enum("ERROR_CODE","ERROR_CLUB_OP_JOIN_CHECK"),
    ERROR_CLUB_OP_JOIN_REPEATED = pb.enum("ERROR_CODE","ERROR_CLUB_OP_JOIN_REPEATED"),
    ERROR_CLUB_OP_EXIT_REPEATED = pb.enum("ERROR_CODE","ERROR_CLUB_OP_EXIT_REPEATED"),
    ERROR_JOIN_ROOM_CARD_NO = pb.enum("ERROR_CODE","ERROR_JOIN_ROOM_CARD_NO"),
    ERROR_CLUB_OP_JOIN_CHECKED = pb.enum("ERROR_CODE","ERROR_CLUB_OP_JOIN_CHECKED"),
    ERROR_CLUB_OP_JOIN_REFUSE = pb.enum("ERROR_CODE","ERROR_CLUB_OP_JOIN_REFUSE"),
    ERROR_CREATE_ROOM_NO = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_NO"),
    ERROR_CREATE_ROOM_CLUB_RULE = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_CLUB_RULE"),
    ERROR_CREATE_ROOM_CLUB_PLAYERSTATUS = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_CLUB_PLAYERSTATUS"),
    ERROR_CREATE_ROOM_CLUB_MAPINFO = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_CLUB_MAPINFO"),
    ERROR_CREATE_ROOM_GEM_NO = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_GEM_NO"),
    ERROR_CREATE_ROOM_CARD_NO = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_CARD_NO"),
    ERROR_CREATE_ROOM_CLUB_JOIN_NO = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_CLUB_JOIN_NO"),
    ERROR_CREATE_ROOM_CLUB_JOIN_STATUS = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_CLUB_JOIN_STATUS"),
    ERROR_CLUB_UNLOCK_JOIN_STATUS = pb.enum("ERROR_CODE","ERROR_CLUB_UNLOCK_JOIN_STATUS"),
    ERROR_CLUB_UNLOCK_JOIN_CLOSED = pb.enum("ERROR_CODE","ERROR_CLUB_UNLOCK_JOIN_CLOSED"),
    ERROR_CREATE_ROOM_CLUB_JOIN_DELETE = pb.enum("ERROR_CODE","ERROR_CREATE_ROOM_CLUB_JOIN_DELETE"),
    ERROR_CLUB_ADD_PLAYER_NO = pb.enum("ERROR_CODE","ERROR_CLUB_ADD_PLAYER_NO"),
    ERROR_PRODUCT_CHANGE_NO = pb.enum("ERROR_CODE","ERROR_PRODUCT_CHANGE_NO"),
    ERROR_PRODUCT_CHANGE_UP = pb.enum("ERROR_CODE","ERROR_PRODUCT_CHANGE_UP"),
    ERROR_PRODUCT_CHANGE_MONEY_NO = pb.enum("ERROR_CODE","ERROR_PRODUCT_CHANGE_MONEY_NO"),
    ERROR_MAIL_CHECK_NO = pb.enum("ERROR_CODE","ERROR_MAIL_CHECK_NO"),
    ERROR_BINDING_CHECK_NO = pb.enum("ERROR_CODE","ERROR_BINDING_CHECK_NO"),
    ERROR_BINDING_CHECK_ERROR = pb.enum("ERROR_CODE","ERROR_BINDING_CHECK_ERROR"),
    ERROR_BINDING_CHECK_ME = pb.enum("ERROR_CODE","ERROR_BINDING_CHECK_ME"),
    ERROR_BINDING_CHECK_MUTUAL = pb.enum("ERROR_CODE","ERROR_BINDING_CHECK_MUTUAL"),
    ERROR_ACTIVITY_CHECK_NO = pb.enum("ERROR_CODE","ERROR_ACTIVITY_CHECK_NO"),
    ERROR_ACTIVITY_CHECK_OUT = pb.enum("ERROR_CODE","ERROR_ACTIVITY_CHECK_OUT"),
    ERROR_ACTIVITY_CHECK_DISMIS = pb.enum("ERROR_CODE","ERROR_ACTIVITY_CHECK_DISMIS"),
    ERROR_ACTIVITY_HAS_NO_ACTIVITY = pb.enum("ERROR_CODE","ERROR_ACTIVITY_HAS_NO_ACTIVITY"),
    ERROR_PLAYER_IS_LOCKED = pb.enum("ERROR_CODE","ERROR_PLAYER_IS_LOCKED"),
    ERROR_UNABLE_TO_CREATE_ROOM = pb.enum("ERROR_CODE","ERROR_UNABLE_TO_CREATE_ROOM"),
    ERROR_HAS_PLYAERS_IN_CLUB_ROOM = pb.enum("ERROR_CODE","ERROR_HAS_PLYAERS_IN_CLUB_ROOM"),
    ERROR_CREATE_CLUB_FAILED_HAS_NO_RULE_ARGS = pb.enum("ERROR_CODE","ERROR_CREATE_CLUB_FAILED_HAS_NO_RULE_ARGS"),
    ERROR_AGENT_HAS_NO_ZJH_AUTH = pb.enum("ERROR_CODE","ERROR_AGENT_HAS_NO_ZJH_AUTH"),
    ERROR_CLUB_FORBID_PLAY_GAME = pb.enum("ERROR_CODE","ERROR_CLUB_FORBID_PLAY_GAME"),
    ERROR_PLAYER_NOT_EXIST = pb.enum("ERROR_CODE","ERROR_PLAYER_NOT_EXIST"),
    ERROR_DESK_LOCKED = pb.enum("ERROR_CODE","ERROR_DESK_LOCKED"),
    ERROR_AREADY_MEMBER = pb.enum("ERROR_CODE","ERROR_AREADY_MEMBER"),
    ERROR_PLAYER_NOT_IN_ROOM = pb.enum("ERROR_CODE","ERROR_PLAYER_NOT_IN_ROOM"),
    ERROR_IN_GAME = pb.enum("ERROR_CODE","ERROR_IN_GAME"),
    ERROR_LOGIN_INFO_INVAILD = pb.enum("ERROR_CODE","ERROR_LOGIN_INFO_INVAILD"),
    ERROR_NO_HALL_SVR = pb.enum("ERROR_CODE","ERROR_NO_HALL_SVR"),
    ERROR_NO_SUB_SVR = pb.enum("ERROR_CODE","ERROR_NO_SUB_SVR"),
    ERROR_LESS_MIN_LIMIT = pb.enum("ERROR_CODE","ERROR_LESS_MIN_LIMIT"),
    ERROR_GREATE_MMAX_LIMIT = pb.enum("ERROR_CODE","ERROR_GREATE_MMAX_LIMIT"),
    ERROR_NOT_OPEN_GAME_AUTH = pb.enum("ERROR_CODE","ERROR_NOT_OPEN_GAME_AUTH"),
    ERROR_LIMIT_MAX_RULE = pb.enum("ERROR_CODE","ERROR_LIMIT_MAX_RULE"),
    ERROR_RULE_NOT_EXIST = pb.enum("ERROR_CODE","ERROR_RULE_NOT_EXIST"),
    ERROR_NO_AUTH = pb.enum("ERROR_CODE","ERROR_NO_AUTH"),
    ERROR_FORCE_DISBAND = pb.enum("ERROR_CODE","ERROR_FORCE_DISBAND"),
    ERROR_LESS_PLAYERS = pb.enum("ERROR_CODE","ERROR_LESS_PLAYERS"),
    ERROR_PLAYER_LEAVE = pb.enum("ERROR_CODE","ERROR_PLAYER_LEAVE"),
    ERROR_PLAYER_IN_ROOM = pb.enum("ERROR_CODE","ERROR_PLAYER_IN_ROOM"),
    ERROR_LESS_GOLDS_SEND_MAJIC_PROPS = pb.enum("ERROR_CODE","ERROR_LESS_GOLDS_SEND_MAJIC_PROPS"),
    ERROR_UN_READY_PLAYER_LEAVE = pb.enum("ERROR_CODE","ERROR_UN_READY_PLAYER_LEAVE"),
    ERROR_DO_REQ_MATCH_NO_TIPS = pb.enum("ERROR_CODE","ERROR_DO_REQ_MATCH_NO_TIPS"),
    ERORR_PARAMETER_ERROR = pb.enum("ERROR_CODE","ERORR_PARAMETER_ERROR"),
    ERROR_TABLE_TEMPLATE_NOT_FOUND = pb.enum("ERROR_CODE","ERROR_TABLE_TEMPLATE_NOT_FOUND"),
    ERROR_CHIP_LESS_THAN_TABLE_MIN_CHIP = pb.enum("ERROR_CODE","ERROR_CHIP_LESS_THAN_TABLE_MIN_CHIP"),
    ERROR_BANKRUPTCY_WARNING = pb.enum("ERROR_CODE","ERROR_BANKRUPTCY_WARNING"),
    ERROR_PLAYER_NO_RIGHT = pb.enum("ERROR_CODE","ERROR_PLAYER_NO_RIGHT"),
    ERROR_CLUB_JOIN_REPEATED = pb.enum("ERROR_CODE","ERROR_CLUB_JOIN_REPEATED"),
    ERROR_OPERATOR_REPEATED = pb.enum("ERROR_CODE","ERROR_OPERATOR_REPEATED"),

    STANDUP_REASON_NORMAL = pb.enum("STANDUP_REASON","STANDUP_REASON_NORMAL"),
    STANDUP_REASON_DISMISS = pb.enum("STANDUP_REASON","STANDUP_REASON_DISMISS"),
    STANDUP_REASON_OFFLINE = pb.enum("STANDUP_REASON","STANDUP_REASON_OFFLINE"),
    STANDUP_REASON_FORCE = pb.enum("STANDUP_REASON","STANDUP_REASON_FORCE"),

    CRT_BOSS = pb.enum("CLUB_ROLE_TYPE","CRT_BOSS"),
    CRT_PLAYER = pb.enum("CLUB_ROLE_TYPE","CRT_PLAYER"),
    CRT_ADMIN = pb.enum("CLUB_ROLE_TYPE","CRT_ADMIN"),
    CRT_PARTNER = pb.enum("CLUB_ROLE_TYPE","CRT_PARTNER"),
    CRT_NOT_MEMBER = pb.enum("CLUB_ROLE_TYPE","CRT_NOT_MEMBER"),

    CT_DEFAULT = pb.enum("CLUB_TYPE","CT_DEFAULT"),
    CT_UNION = pb.enum("CLUB_TYPE","CT_UNION"),

    MAIL_OPT_RESULT_SUCCESS = pb.enum("MAIL_OPT_RESULT", "MAIL_OPT_RESULT_SUCCESS"),
    MAIL_OPT_RESULT_FIND_FAILED = pb.enum("MAIL_OPT_RESULT", "MAIL_OPT_RESULT_FIND_FAILED"),
    MAIL_OPT_RESULT_EXPIRATION = pb.enum("MAIL_OPT_RESULT", "MAIL_OPT_RESULT_EXPIRATION"),
    MAIL_OPT_RESULT_NO_ATTACHMENT = pb.enum("MAIL_OPT_RESULT", "MAIL_OPT_RESULT_NO_ATTACHMENT"),
    MAIL_OPT_RESULT_HAS_ATTACHMENT = pb.enum("MAIL_OPT_RESULT", "MAIL_OPT_RESULT_HAS_ATTACHMENT"),

    ITEM_TYPE_MONEY = pb.enum("ITEM_TYPE", "ITEM_TYPE_MONEY"),
    ITEM_TYPE_BOX  = pb.enum("ITEM_TYPE", "ITEM_TYPE_BOX"),
    
    ROOM_CARD_ID = pb.enum("MONEY_CONST_ID","ROOM_CARD"),
}

return enums
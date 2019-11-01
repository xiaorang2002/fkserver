local skynet = require "skynet"
local channel = require "channel"
local netmsgopt = require "netmsgopt"
local cluster = require "cluster"
local client_handle = require "gate.msg.on_client"
local gbk = require "gbk"
local util = require "gate.util"
local crypt = require "skynet.crypt"
local httpc = require "http.httpc"
local datacenter = require "skynet.datacenter"
require "table_func"
require "functions"
local log = require "log"

local log.info = log.info
local log.error = log.error
local log.warning = log.warning


skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.tostring,
}

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.unpack,
}

local gate = ...
gate = tonumber(gate)
local fd
local addr
local guid
local conf
local serverid
local rsa_public_key

local function toguid(msgname,msg)
    assert(fd,"toguid,fd ~= nil")
    assert(guid,"toguid,guid ~= nil")
    
	netmsgopt.write(fd,guid,msgname,msg)
end

local CMD = {}


function CMD.login(source, u)
	-- you may use secret to make a encrypted data stream
	log.info(string.format("%s is login", u.guid))
	gate = source
    guid = u.guid
    fd = u.fd
    addr = u.addr
    conf = u.conf
	-- you may load user data from database
end

local function logout()
	if gate then
		skynet.call(gate, "lua", "logout", guid)
	end
	skynet.exit()
end

function CMD.logout(source)
	-- NOTICE: The logout MAY be reentry
	skynet.error(string.format("%s is logout", guid))
	logout()
end

function CMD.afk(source)
	-- the connection is broken, but the user may back
	skynet.error(string.format("AFK"))
end

function CMD.enterserver(source,id)
	serverid = id
end

function CMD.push(msgname,msg)
	netmsgopt.write(fd,guid,msgname,msg)
end


local MSG = {}

function MSG.C_RequestPublicKey(guid,msg)
    if not rsa_public_key then
        rsa_public_key = skynet.public_key()
    end

    netmsgopt.write(fd,guid,"C_PublicKey",{
        public_key = rsa_public_key,
    })
end

function MSG.CS_RequestSms(guid,msg)
	if not util.request_sms(guid) then
		log.info( "RequestSms guid [%d]",guid)
		toguid("SC_RequestSms",{
            result = LOGIN_RESULT_SMS_REPEATED,
        })
	else
        log.info( "RequestSms guid [%d] =================", guid )
        if not msg.tel then
            log.error( "RequestSms guid [%d] =================tel not find", get_guid() )
            netmsgopt.write(fd,0,"SC_RequestSms",{
                result = LOGIN_RESULT_SMS_FAILED,
            } )
            return true
        end

        local tel = msg.tel

        log.info( "RequestSms guid [%d] =================tel[%s] platform_id[%s]",  msg.tel, msg.platform_id)
        local tellen = string.len(tel)
        if tellen < 7 or tellen > 18 then
            netmsgopt.write(fd,0,"SC_RequestSms",{
                result = LOGIN_RESULT_TEL_LEN_ERR,
            })
            return true
        end

        local tel_head = string.sub(tel,0, 3)

        --170 171的不准绑定
        if tel_head == "170" or tel_head == "171" then
            netmsgopt.write(fd,0,"SC_RequestSms",{
                result = LOGIN_RESULT_TEL_ERR,
            } )
            return true
        end

        if tel_head == "999" then
            tel_head =  string.sub(tel,tellen - 6)
            sms_status.tel = tel
            sms_status.sms_no = tel_head
            sms_status.last_sms_time = os.time()
            return true
        end

        if not string.gmatch(tel,"^\\d+&")() then
            netmsgopt.write(fd,0,"SC_RequestSms",{
                result = LOGIN_RESULT_TEL_ERR,
            })
            return true
        end

        -- if msg.intention == 2 then
        --     auto session = GateSessionManager::instance().get_login_session()
        --     if session then
        --         msg.gate_session_id =  get_id
        --         msg.guid =  guid
        --         msg.gate_id( static_cast<GateServer*>(BaseServer::instance()).get_gate_id() )
        --         log.info( "gateid[%d] guid[%d] sessiong[%d]", static_cast<GateServer*>(BaseServer::instance()).get_gate_id(), get_guid(), get_id() )
        --         session.toguid( &msg )
        --     else
        --         log.warning( "login server disconnect" )
        --     end
        -- else
        --     do_get_sms_http( msg.tel, msg.platform_id )
        -- end
    end

	return true
end

function MSG.CG_GameServerCfg(msg)
    local player_platform_id = "0"
    
    if not msg.platform_id then
        log.warning( "platform_id empty, CG_GameServerCfg, set platform = [0]")
    else
        player_platform_id = msg.platform_id
    end

    local pb_cfg = {}
	for _,item in pairs(online_server) do
		if item.platform_id and game_cfg[item.game_id].is_open then
            log.error( "GameName[%s] GameID[%d] platform[%s] error.", item.game_name, item.game_id, item.platform_id )
			for _,it in pairs(string.split(item.platform_id,"[^,]+")) do
				if player_platform_id == it then
					table.insert(pb_cfg,item)
					break
                end
			end
        end
	end

	for _,p in pairs(pb_cfg) do
		log.info( "GC_GameServerCfg[%s] ==> %s", p.game_name, p.title )
    end

	toguid("GC_GameServerCfg",{
        pb_cfg = pb_cfg,
    })

	return true
end

function MSG.CL_GetInviterInfo(msg) 
    if not msg.invite_code then
        log.error( "no invite_code, guid=%d", guid)
        return false
    end

    msg.guid = guid
    local scmsg = channel.call("login.?","msg","CL_GetInviterInfo",{
        guid = guid,
    })

    toguid("LC_GetInviterInfo",scmsg)
end

function MSG.CS_SetNickname(msg) 
    if not msg.nickname then
        toguid("SC_SetNickname",{
            result = LOGIN_RESULT_NICKNAME_EMPTY,
        })
        return true
    end

    local reply = {
        nickname = msg.nickname,
    }
    local gbknickname = gbk.fromutf8(msg.nickname)
    local nicknamelen = gbk.len(gbknickname)
    if nicknamelen < 4 or nicknamelen > 14 then
        toguid("SC_SetNickname",{
            result = LOGIN_RESULT_NICKNAME_LIMIT,
        })
        return true
    end

    local scmsg = channel.call(":.game.?","msg","CS_SetNickname",msg)
    toguid("SC_SetNickname",scmsg)

	return true
end


function MSG.CS_ResetAccount(msg) 
	if not serverid then
		log.warning( "game_id == 0" )
		return false
    end

    local reset_account_reply = {
        nickname = msg.nickname,
    }

    if not msg.nickname then
        reset_account_reply.result = LOGIN_RESULT_NICKNAME_EMPTY
        toguid("SC_ResetAccount",reset_account_reply)
        return true
    end

    if not msg.password then
        reset_account_reply.result = LOGIN_RESULT_SET_ACCOUNT_OR_PASSWORD_EMPTY
        toguid("SC_ResetAccount",reset_account_reply)
        log.error( "password empty" )
        return true
    end

    local gbk_nickname = gbk.fromutf8(msg.nickname)
    local nickname_len = gbk.len(gbk_nickname)
    if nickname_len < 4 or nickname_len > 14 then
        reset_account_reply.result = LOGIN_RESULT_NICKNAME_LIMIT
        toguid("SC_ResetAccount",reset_account_reply)
        return true
    end

    local password = util.rsa_decrypt(crypt.hexdecode(msg.password))
    if type(password) ~= "string" then
        reset_account_reply.result = LOGIN_RESULT_SET_ACCOUNT_OR_PASSWORD_EMPTY
        toguid("SC_ResetAccount",reset_account_reply)
        log.error( "password error %s", msg.password() )
        return true
    end

    if not msg.account then
        reset_account_reply.result = LOGIN_RESULT_SET_ACCOUNT_OR_PASSWORD_EMPTY
        toguid("SC_ResetAccount",reset_account_reply)
        log.error( "CE_ResetAccount account empty" )
        return true
    end

    if msg.type == 2 then
        local potato_key = util.rsa_decode(crypt.hexdecode(msg.account))
        local potato_reset_nickname = msg.nickname
        local potato_reset_password = password
        local potato_login_access_token = msg.key

        local potatoconf = datacenter.query("potato.config")
        local postparam = {
            access_token = potato_login_access_token,
            client_secret = potato_key,
        }

        local host,url = string.match(potatoconf.url,"https?://([^/]+)/?([^\\?]*)")
        local jsonrep = httpc.post(host,url,postparam)
        if not jsonrep then
            return true
        end

        local rep = json.decode(jsonrep)
        local success = rep.success
        local code = rep.code
        if success then
            local data = rep.data
            if not data or type(data) ~= "table" then
                return
            end

            local phone = data.phone
            if not phone or type(phone) ~= "string" then
                return
            end

            local scmsg = channel.call("game."..tostring(serverid),"msg","CS_ResetAccount",{
                account = phone,
                password = potato_reset_password,
                nickname = potato_reset_nickname,
            })

            toguid("SC_ResetAccount",scmsg)
        else
            if code then
                log.error( "potato login is error : code[%d] message[%s]", code, rep.message )
            else
                log.error( "potato login is error : code[%d] ", LOGIN_RESULT_POTATO_CHECK_ERROR )
            end
        end

        reset_account_reply.result = code and tonumber(code) or LOGIN_RESULT_POTATO_CHECK_ERROR
        toguid("SC_ResetAccount", reset_account_reply)
        return
    end

    if not msg.account or type(msg.account) ~= "string" then
        reset_account_reply.result = LOGIN_RESULT_SET_ACCOUNT_OR_PASSWORD_EMPTY
        toguid("SC_ResetAccount",reset_account_reply)
        log.error( "CE_ResetAccount account empty" )
        return true
    end

    reset_account_reply.account = msg.account

    if string.len(msg.account) > 18 or string.len(msg.account < 7) then
        reset_account_reply.result = LOGIN_RESULT_ACCOUNT_SIZE_LIMIT
        toguid("SC_ResetAccount",reset_account_reply)
        return true
    end

    if string.find(msg.account,"$[^\\d]+^") then
        reset_account_reply.result = LOGIN_RESULT_ACCOUNT_CHAR_LIMIT
        toguid("SC_ResetAccount",reset_account_reply)
        return true
    end

    if not util.verify_sms(guid,msg.account,msg.key) then
        reset_account_reply.result = LOGIN_RESULT_SMS_FAILED
        toguid("SC_ResetAccount",reset_account_reply)
        return true
    end

    if not msg.key or not string.find(msg.key,"$[^\\d]+^") or string.len(msg.key) ~= 6 then
        reset_account_reply.result = LOGIN_RESULT_SMS_ERR
        toguid("SC_ResetAccount",reset_account_reply)
        return true
    end

    msg.password = password
    msg.guid = guid
    local scmsg = channel.call("game."..tostring(serverid),"msg","CS_ResetAccount",msg)
    toguid("SC_ResetAccount",scmsg)

	return true
end


function MSG.CS_SetPassword(guid,msg) 
	if serverid == 0 then
		log.warning( "game_id == 0" )
		return false
    end

    if not msg.old_password or not msg.password then
        log.error( "password or old password empty" )
        return
    end

    if not msg.old_password or not msg.password then
        log.error( "old new password error %s,%s", msg.old_password, msg.password )
        return false
    end

    local old_password = util.rsa_decrypt(crypt.hexdecode(msg.old_password))
    local password = util.rsa_decrypt(crypt.hexdecode(msg.password))
    if not old_password or not password then
        log.error( "old new password error %s,%s", msg.old_password, msg.password )
        return false
    end

    if old_password == password then
        toguid("SC_SetPassword",{
            result = LOGIN_RESULT_SAME_PASSWORD,
        } )
        return true
    end

    msg.old_password =  old_password
    msg.password = password
    msg.guid = guid
    
    local scmsg = channel.call("game."..tostring(serverid),"msg","CS_SetPassword",msg)
    toguid("SC_SetPassword",scmsg)

	return true
end

function MSG.CS_SetPasswordBySms(guid,msg) 
    if not serverid then
		log.warning( "game_id == 0" )
		return false
    end
    if not msg.password then
        log.error( "password empty" )
        return
    end

    msg.guid = guid

    if not util.verify_sms(guid,msg.tel,msg.sms_no) then
        toguid("SC_SetPassword",{
            result = LOGIN_RESULT_SMS_FAILED,
        })
        return true
    end

    msg.password = util.rsa_decrypt(crypt.hexdecode(msg.password))
    local scmsg = channel.call("game."..tostring(serverid),"msg","CS_SetPasswordBySms",msg)
    toguid("SC_SetPasswordBySms",scmsg)

	return true
end

function MSG.CS_BankSetPassword(guid,msg) 
	if serverid == 0 then
		log.warning( "game_id == 0" )
		return false
    end

    if msg.password then
        msg.guid = guid
        msg.password = util.rsa_decrypt(crypt.hexdecode(msg.password))
        local scmsg = channel.call("game."..tostring(serverid),"msg","CS_BankSetPassword",msg)
        toguid("SC_BankSetPassword",scmsg)
    else
        log.error( "CS_BankSetPassword password empty" )
    end

	return true
end

function MSG.CS_BankChangePassword(guid,msg) 
	if serverid == 0 then
		log.warning( "game_id == 0" )
		return false
    end
    
    if msg.old_password and msg.password then
        msg.guid = guid
        msg.old_password = util.rsa_decrypt(crypt.hexdecode(msg.old_password))
        msg.password = util.rsa_decrypt(crypt.hexdecode(msg.password))
        local scmsg = channel.call("game."..tostring(serverid),"msg","CS_BankChangePassword",msg)
        toguid("SC_BankChangePassword",scmsg)
    else
        log.error( "CS_BankChangePassword password or old password empty" )
    end

	return true
end

function MSG.CS_BankReSetPassWD(guid,msg) 
	if serverid == 0 then
		log.warning( "game_id == 0" )
		return false
    end

    if not util.verify_sms(guid,msg.tel,msg.bank_pw_sms) then
        toguid("SC_ResetBankPW",{
            guid = msg.guid,
            result = LOGIN_RESULT_SMS_FAILED,
        } )
    else
        msg.bank_password_new = util.rsa_decrypt(crypt.hexdecode(msg.bank_password_new))
        msg.guid = guid
        local scmsg = channel.call("game."..tostring(serverid),"msg","CS_BankReSetPassWD",msg)
        toguid("SC_BankChangePassword",scmsg)
    end

	return true
end

function MSG.CS_BankDraw(guid,msg) 
	if serverid == 0 then
		log.warning( "game_id == 0" )
		return false
    end

    msg.guid = guid
    if msg.bank_password then
        msg.bank_password = util.rsa_decrypt(crypt.hexdecode(msg.bank_password))
    end

    local scmsg = channel.call("game."..tostring(serverid),"msg","CS_BankDraw",msg)
    toguid("SC_BankDraw",scmsg)

	return true
end

function MSG.CS_BankLogin(guid,msg) 
	if serverid == 0 then
		log.warning( "game_id == 0" )
		return false
    end

    if msg.password then
        msg.password = util.rsa_decrypt(crypt.hexdecode(msg.password))
        local scmsg = channel.call("game."..tostring(serverid),"msg","CS_BankLogin",msg)
        toguid("SC_BankDraw",scmsg)
    else
        log.error( "CS_BankLogin password empty" )
    end

	return true
end

function MSG.SS_JoinPrivateRoom(msg)
    -- msg.owner_game_id = s.get_game_server_id 
    -- msg.first_game_type = s.get_first_game_type 
    -- msg.second_game_type = s.get_second_game_type 
    -- msg.private_room_score_type = s.get_private_room_score_type
	
	-- channel.publish("game."..tostring(msg.game_id),"SS_JoinPrivateRoom",msg)
end


local function heartbeat()
	netmsgopt.write(fd,guid,"")
end

local function dispatch_client(_,msgname,msg)
	if msgname == "S_Heartbeat" then
		heartbeat()
		return
	end

	if client_handle[msgname] then
		client_handle[msgname](guid,msg)
		return
	end

	if serverid then
		channel.publish(serverid,"client",guid,msgname,msg)
	else
		skynet.error(string.format("player %d isn't in server,but recv msg data.",guid))
	end
end



skynet.start(function()
	-- If you want to fork a work thread , you MUST do it in CMD.login
	skynet.dispatch("lua", function(_, source, command, ...)
		local f = assert(CMD[command])
		skynet.ret_pack(f(source, ...))
	end)

	skynet.dispatch("client", function(_,source,...)
		dispatch_client(source,...)
	end)

	skynet.dispatch("text",function(_,_,msgname,msg) 
		toguid(msgname,msg)
	end)

	cluster.register("guid."..tostring(guid),skynet.self())
end)

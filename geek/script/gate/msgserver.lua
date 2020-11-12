local skynet = require "skynetproto"
local assert = assert
local log = require "log"
local netmsgopt = require "netmsgopt"

local protocol = protocol
local gateserver

local server = {}

local connection = {}

function server.close(fd)
	local u = connection[fd]
	connection[fd] = nil
	
	if u then
		u.fd = nil
	end

	gateserver.closeclient(fd)
end

function server.ip(fd)
	local u = connection[fd]
	if u and u.fd then
		return u.ip
	end
end

function server.start(conf)
	gateserver = require(protocol == "ws" and "gate.gateserver_ws" or "gate.gateserver")

	local expired_number = conf.expired_number or 128

	local handler = {}

	function handler.command(cmd, source, ...)
		local f = assert(conf[cmd])
		return f(...)
	end

	function handler.open(source, gateconf)
		
	end

	function handler.connect(fd, addr)
		gateserver.openclient(fd)
		local ip,port = addr:match("([^:]+)%s*:%s*(%d+)")
		port = tonumber(port)
		connection[fd] = {
			fd = fd,
			ip = ip,
			port = port,
			expired = false,
			open_time = os.time(),
		}
	end

	function handler.disconnect(fd)
		local c = connection[fd]
		if c then
			if c.guid and conf.disconnect_handler then
				conf.disconnect_handler(c)
			end
			connection[fd] = nil
		end
	end

	handler.error = handler.disconnect
	local request_handler = assert(conf.request_handler)

	local function do_request(fd,msgstr)
		local ok, err = pcall(request_handler, msgstr,connection[fd])
		-- not atomic, may yield
		if not ok then
			log.error("Invalid package %s : %s", err, msgstr)
			if connection[fd] then
				gateserver.closeclient(fd)
			end
		end
	end

	function handler.message(fd, msgstr)
		local c = connection[fd]
		if not c then
			log.error("request arrive,got nil connection,maybe closed,%d",fd)
			return
		end
		
		return do_request(fd,msgstr)
	end

	return gateserver.start(handler)
end

return server

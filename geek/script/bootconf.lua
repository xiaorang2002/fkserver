local skynet = require "skynet"
local log = require "log"
local channel = require "channel"
local bootconf = require "conf.boot"
local callmod = require "callmod"

local string = string
local table = table
local tolower = string.lower
local strfmt = string.format
local tinsert = table.insert
local tunpack = table.unpack
local tconcat = table.concat

local cmdlines = {...}

local args = {}
for i = 2,#cmdlines do
	tinsert(args,cmdlines[i])
end

local function cluster_name(conf)
    return conf.name .. "." .. conf.id
end

local function cluster_hostaddr(conf)
    return conf.port and conf.host .. ":" .. conf.port or conf.host
end

local function service_id(conf)
    return conf.name .. "." .. conf.id
end

local function setupbootservice()
    local bootnode = bootconf.node
    local name = cluster_name(bootnode)
    local addr = cluster_hostaddr(bootnode)
	channel.subscribe(service_id(bootconf.service),{
		provider = name,
		addr = addr,
	})
end


local function setup()
    setupbootservice()
    
    local serviceconfs = channel.call(bootconf.service.name..".?","msg","query_service_conf")
    local clusterconfs = channel.call("config.?","msg","query_cluster_conf")

	local services = {}

    for _,cs in pairs(serviceconfs) do
        if cs.is_launch ~= 0 then
			local sid = service_id(cs)
			local cconf = clusterconfs[cs.cluster]
			if sid and cconf then
				local cid = cluster_name(cconf)
				services[sid] = cid .. "@" .. sid
			end
        end
    end

    channel.subscribe(services)
end


local conf_handle = {
	reload = function()
		local sidmod = args[1]
		for sid,_ in pairs(channel.query("config.*")) do
			local ok = channel.pcall(sid,"lua","cleancache")
			assert(ok,strfmt("clean config cache failed,%s",sid))
		end
		local sids = channel.query(sidmod)
		for sid,_ in pairs(sids) do
			log.info("reloadconf %s",sid)
			local ok = channel.pcall(sid,"lua","reloadconf")
			log.info("reloadconf %s end: %s",sid,ok)
		end
	end,
	usage = function()
		local lines = {
			"conf usage:",
			"reload sid: reload service config of sid from db",
		}
		print(tconcat(lines,"\n"))
	end,
}

skynet.start(function()
	setup()

	local fn = conf_handle[tolower(cmdlines[1])] or conf_handle.usage
	if fn then
		fn()
	end

	require "skynet.manager"
	skynet.abort()
end)
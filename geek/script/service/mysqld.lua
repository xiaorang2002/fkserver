-- db操作相关
require "functions"
local log = require "log"
local skynet = require "skynetproto"
local mysql = require "skynet.db.mysql"
local channel = require "channel"

LOG_NAME = "mysqld"

collectgarbage("setpause", 100)
collectgarbage("setstepmul", 1000)

local table = table
local assert = assert
local string = string
local tinsert = table.insert
local tremove = table.remove

local query_ttl_time = 3

local connection = {}

function connection:close()
	if not self.conn then 
		return 
	end
	self.conn:disconnect()
	self.conn = nil
end

function connection:query(sql)
	if not self.conn then 
		log.errro("connection:query conn is nil.")
		return
	end
	return self.conn:query(sql)
end

function new_connection(cfg)
	local conn = mysql.connect({
		host=cfg.host or "127.0.0.1",
		port=cfg.port or 3306,
		database=cfg.database,
		user=cfg.user or "root",
		password=cfg.password,
		max_packet_size = 1024 * 1024,
		on_connect = function(db)
			db:query("set charset utf8;");
		end,
	})

	if not conn then
		log.error("mysql failed to connect")
		return
	end

	return setmetatable({
		conn = conn,
	},{
		__index = connection,
		__gc = function(t)
			t:close()
		end
	})
end

local connection_pool = {}

function new_connection_pool(conf)
	assert(conf)
	log.dump(conf)
	return setmetatable({
		__conf = conf,
		__min= conf.pool or 8,
		__free = {},
		__waiting = {},
		__trans = {},
	},{
		__index = connection_pool,
		__gc = function(pool)
			pool:close()
		end,
	})
end

function connection_pool.wait(pool)
	local co = coroutine.running()
	tinsert(pool.__waiting,co)
	skynet.wait()
end

function connection_pool.wakeup(pool)
	local co = tremove(pool.__waiting,1)
	if co then
		skynet.wakeup(co)
	end
end

function connection_pool.close(pool)
	local conn
	repeat
		conn = tremove(pool.__free,1)
		if conn then
			conn:close()
		end
	until not conn
end

function connection_pool.occupy(pool)
	for _ = 1,1000 do
		local conn = tremove(pool.__free,1)
		if conn then
			return conn
		end

		local ok
		ok,conn = pcall(new_connection,pool.__conf)
		if ok and conn then
			return conn
		end
		
		pool:wait()
	end
end

local function reserve_guard(pool)
	local conn
	while #pool.__free > pool.__min do
		conn = tremove(pool.__free,1)
		if conn then
			conn:close()
		end
	end
end

function connection_pool.release(pool,conn)
	tinsert(pool.__free,conn)

	pool:wakeup()

	reserve_guard(pool)
end

function connection_pool.query(pool,fmtsql,...)
	local starttime = skynet.time()
	local conn = pool:occupy()
	local ok,res = pcall(conn.query,conn,fmtsql,...)
	if not ok then
		log.error("msyqld connection_pool query got error,%s",res)
		pool:release(conn)
		error(res)
		return
	end
	pool:release(conn)
	local delta = skynet.time() - starttime
	if delta > query_ttl_time then
		log.warning("msyqld connection_pool.query max_ttl %s,sql:\"%s\"",delta,fmtsql)
	end
	return res
end

function connection_pool.begin_transaction(pool)
	local transid = #pool.__trans + 1
	local conn = pool:occupy()
	conn:query([[SET AUTOCOMMIT = 0;BEGIN;]])
	pool.__trans[transid] = conn
	return transid
end

function connection_pool.do_transaction(pool,transid,fmtsql,...)
	local conn = pool.__trans[transid]
	assert(conn,string.format("do_transaction got nil conn with id %s.",transid))
	
	return conn:query(fmtsql,...)
end

function connection_pool.finish_transaction(pool,transid)
	local conn = pool.__trans[transid]
	if conn then
		pool:release(conn)
	end
	pool.__trans[transid] = nil
end

local dbconfs = setmetatable({},{
	__index = function(t,name)
		local confs = channel.call("config.?","msg","query_database_conf")
		for _,conf in pairs(confs) do
			rawset(t,conf.name,conf)
		end

		return rawget(t,name)
	end
})

local dbpools = setmetatable({},{
	__index = function(t,name)
		local pool = new_connection_pool(dbconfs[name])
		t[name] = pool
		return pool
	end
})

local function opendb(conf)
	local name = conf.name
	dbconfs[name] = conf
	dbpools[name] = nil
	
	return dbconfs[name]
end

local function closedb(name)
	dbconfs[name] = nil
	local pool = dbpools[name]
	if pool then
		pool:close()
		dbpools[name] = nil
	end
end

local CMD = {}

function CMD.query(dbname,fmtsql,...)
	local pool = dbpools[dbname]
	if not pool then 
		log.error("mysqld CMD.query got nil pool,db:%s",dbname)
		return 
	end

	local res = pool:query(fmtsql,...)
	return res
end

function CMD.begin_transaction(dbname)
	local pool = dbpools[dbname]
	if not pool then 
		log.error("mysqld CMD.do_transaction got nil pool,db:%s",dbname)
		return 
	end

	return pool:begin_transaction([[SET AUTOCOMMIT = 0;BEGIN;]])
end

function CMD.do_transaction(dbname,transid,fmtsql,...)
	local pool = dbpools[dbname]
	if not pool then 
		log.error("mysqld CMD.do_transaction got nil pool,db:%s",dbname)
		return 
	end

	return pool:do_transaction(transid,fmtsql,...)
end

function CMD.rollback_transaction(dbname,transid)
	local pool = dbpools[dbname]
	if not pool then 
		log.error("mysqld CMD.do_transaction got nil pool,db:%s",dbname)
		return 
	end

	local res = pool:do_transaction(transid,[[ROLLBACK;SET AUTOCOMMIT = 1;]])
	pool:finish_transaction(transid)
	return res
end

function CMD.commit_transaction(dbname,transid)
	local pool = dbpools[dbname]
	if not pool then 
		log.error("mysqld CMD.do_transaction got nil pool,db:%s",dbname)
		return 
	end

	local res = pool:do_transaction(transid,[[COMMIT;SET AUTOCOMMIT = 1;]])
	pool:finish_transaction(transid)
	return res
end

function CMD.open(cfg)
	opendb(cfg)
end

function CMD.close(dbname)
	closedb(dbname)
end

skynet.start(function()
	skynet.dispatch("lua", function (_, _, cmd, ...)
		local f = CMD[cmd]
		if f then
			skynet.retpack(f(...))
		else
			log.error("unknown cmd:"..cmd)
			skynet.retpack(nil)
		end
	end)

	require "skynet.manager"
	local handle = skynet.localname ".mysqld"
	if handle then
		skynet.exit()
		return handle
	end

	skynet.register ".mysqld"
end)

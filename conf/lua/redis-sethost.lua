
-- UTILS --

-- https://gist.github.com/jrus/3197011
local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- REDIS ---

local redis = require "resty.redis"
local red = redis:new()

red:set_timeouts(1000, 1000, 1000) -- 1 sec

-- connect via ip address directly
local ok, err = red:connect(os.getenv("REDIS_HOST"), os.getenv("REDIS_PORT"))

if not ok then
    ngx.say("failed to connect: ", err)
    return
end


local function closeRedis(red)
  -- or just close the connection right away:
  local ok, err = red:close()
  if not ok then
       -- ngx.say("failed to close: ", err)
       return
  end
end

local function isempty(s)
  return s == nil or s == ''
end

local sshhost = ngx.var.arg_host
if isempty(sshhost) then
  sshhost = "localhost"
end

-- local uuidx = uuid()

-- TODO read username password from file

-- redis.set("12.39.32.7", "root@r2342")
-- redis.set("12.39.32.7", "root@r2342")
-- redis.set("12.39.32.7", "root@r2342")
-- {host: username:pass}

-- local res, err = red:get(sshhost)

local ok, err = red:set("host_" .. sshhost, "term:term") --.. "_" .. uuidx,  res)
if not ok then
    ngx.say("failed to set <username:password> for host: ", err)
    return closeRedis(red)
end

ngx.say("set result: ", ok)

closeRedis(red)


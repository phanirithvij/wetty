-- UTILS --

-- https://stackoverflow.com/a/35303321/8608146
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding

-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- https://stackoverflow.com/a/7615129/8608146
function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end


-- REDIS --

-- https://github.com/openresty/lua-resty-redis#synopsis

local redis = require "resty.redis"
local red = redis:new()

red:set_timeouts(1000, 1000, 1000) -- 1 sec

-- connect via ip address directly
local ok, err = red:connect(os.getenv("REDIS_HOST"), os.getenv("REDIS_PORT"))


local function closeRedis(red)
  -- or just close the connection right away:
  local ok, err = red:close()
  if not ok then
       -- ngx.say("failed to close: ", err)
       return
  end
end

if not ok then
    -- ngx.say("failed to connect: ", err)
    return closeRedis(red)
end

local function isempty(s)
  return s == nil or s == ''
end


local sshhost = ngx.var.arg_host
if isempty(sshhost) then
  local refex = ngx.req.get_headers()["referer"]
  if not isempty(refex) then
    local uri = mysplit(refex, "?")[2]
    if isempty(uri) then
      ngx.log(ngx.STDERR, "***************" .. "\nreferer:" .. refex ..  "\narg_host:" .. dump(ngx.var.arg_host) .. "\n***************")
      return closeRedis(red)
    end
    local params = ngx.decode_args(uri)
    sshhost = params["host"]
    -- ngx.log(ngx.STDERR, "***************\n" .. refex .. " , " .. dump(params) .. "\n****************")
    if isempty(sshhost) then
      ngx.log(ngx.STDERR, "***************" .. "\nreferer:" .. refex ..  "\narg_host:" .. dump(ngx.var.arg_host) .. "\n***************")
      return closeRedis(red)
    end
  end
end

if isempty(sshhost) then
  return closeRedis(red)
end

-- local uuid = "";
-- local uuid = ngx.var.wetty_uuid;

local res, err = red:get("host_" .. sshhost) -- .. "_" .. uuid)
if not res then
    -- ngx.say("failed to get <username:password> for host: ", err)
    return closeRedis(red)
end

if res == ngx.null then
    -- ngx.say("<username:password> not found.")
    return closeRedis(red)
end

-- ngx.say("<username:password>: ", res)

if not isempty(res) then
  ngx.var.auth_header = enc(res)
  ngx.var.user_name = mysplit(res, ":")[1]
else
  ngx.var.auth_header = "debug-bad-auth-header-empty-res"
  ngx.var.user_name = "debug-bad-username-empty-res"
end

closeRedis(red)

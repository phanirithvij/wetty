-- local redis = require "resty.redis"
-- local red = redis:new()
-- 
-- red:set_timeouts(1000, 1000, 1000) -- 1 sec
-- 
-- -- connect via ip address directly
-- local ok, err = red:connect(os.getenv("REDIS_HOST"), os.getenv("REDIS_PORT"))
-- 
-- if not ok then
    -- ngx.say("failed to connect: ", err)
    -- return
-- end
-- 
-- -- local sshhost = "TODO from url parmeters";
-- -- local uuid = "";
-- 
-- local res, err = red:get("host_" .. sshhost .. "_" .. uuid)
-- if not res then
    -- ngx.say("failed to get <username, password> for host: ", err)
    -- return
-- end
-- 
-- if res == ngx.null then
    -- ngx.say("<username, password> not found.")
    -- return
-- end
-- 
-- ngx.say("<username, password>: ", res)
-- 
-- -- or just close the connection right away:
-- local ok, err = red:close()
-- if not ok then
     -- ngx.say("failed to close: ", err)
     -- return
-- end

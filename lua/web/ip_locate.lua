-- app
local ngx = require "ngx"
local cjson = require "cjson.safe"
local qqwry = require("qqwry")

local DATA="/var/wd/ip_locate/nginx/conf/lua/web/qqwry.dat"
local IP_NOT_FOUND = '{"status":404, "message":"IP地址找不到", "more info":"定位数据库中无法找到"}'
local IP_INVALID = '{"status":400, "message":"查询参数无效", "more info":"查询参数无效"}'

ngx.update_time()
local request_st = ngx.now()

ngx.log(ngx.DEBUG, "ngx.var.uri:", "[", ngx.var.uri, "]")

if ngx.var.uri ~= "/query" then
    ngx.log(ngx.INFO, string.format("url path not found"))
    ngx.exit(ngx.HTTP_NOT_FOUND)
    return
end

uri_args = ngx.req.get_uri_args()

ngx.header.content_type = "application/json; charset=UTF-8"

if uri_args and uri_args["ip"] then
    local ip = uri_args["ip"]
    ngx.log(ngx.INFO, "ip:", ip)
    result = qqwry.query(DATA, ip)
    if result then
        ngx.header.content_type = "application/json; charset=GB2312"
        ngx.print(string.format('{"status":200, "message":"ok", "data":[{"ip": "%s", "geo": "%s", "location": "%s"}]}', ip, result[1], result[2]))
    else
        ngx.log(ngx.INFO, string.format("ip location not found:", ip))
        ngx.print(ngx.IP_NOT_FOUND)
        ngx.exit(ngx.HTTP_OK)
    end
    -- ngx.print(qqwry.query(ip)[1])
    -- print(qqwry.query(ip)[2])
    -- local t = qqwry.version()
    -- print(table.concat(t))
else
    ngx.log(ngx.INFO, string.format("param[ip] not found"))
    ngx.print(IP_INVALID)
    ngx.exit(ngx.HTTP_OK)
end

--性能统计
ngx.update_time()
local response_st = ngx.now()
ngx.log(ngx.NOTICE, string.format("[ip_locate] response time:%s", response_st-request_st))
--性能统计 END

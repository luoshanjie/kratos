
local cc_printinfo  = cc.printinfo
local string_format = string.format


local value = os.date("%Y-%m-%d %H:%M", os.time())
ngx.say("Kratos is sample API Gateway at " .. value)
cc_printinfo(string_format('返回时间: %s', value))

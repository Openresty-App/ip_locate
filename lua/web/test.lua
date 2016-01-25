local qqwry = require("qqwry")

local ip = "124.238.218.3"
print(qqwry.query(ip)[1])
print(qqwry.query(ip)[2])

local t = qqwry.version()
print(table.concat(t))

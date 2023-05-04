local URL =
	[[https://github.com/Windows81/Roblox-Asset-Varietor/raw/main/anims.json]]
local res = game:HttpGet(URL)
local j = game.HttpService:JSONDecode(res)

local o_entries = {}
for i, d in next, j do
	local o = {string.format('\x1b[90m[%s]\x1b[00m', i)}
	for i, v in next, d do
		table.insert(o, string.format('\x1b[95m%12d\x1b[00m : %s', v, i))
	end
	table.insert(o_entries, table.concat(o, '\n'))
end

_E.OUTPUT = {table.concat(o_entries, '\n\n')}
return j

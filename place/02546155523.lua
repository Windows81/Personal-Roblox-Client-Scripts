local fn = string.format('place/%011d-parties.json', 02546155523)
local data = {}
if isfile(fn) then
	local json = readfile(fn)
	data = game.HttpService:JSONDecode(json)
end

local list = game.ReplicatedStorage.CS.GetPartyList:InvokeServer()
local ts = os.date('%Y-%m-%dT%H:%M:%SZ')
for _, d in next, list do
	local id = d.psid
	d.updated = ts
	data[id] = d
end
writefile(fn, game.HttpService:JSONEncode(data))

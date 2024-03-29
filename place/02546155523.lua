--[==[HELP]==
To be used with "RoVille".
]==] --
--
local fn = string.format('place/%011d-parties.json', 02546155523)
local data = {}
if isfile(fn) then
	local json = readfile(fn)
	data = game.HttpService:JSONDecode(json)
end

repeat
	local list = game.ReplicatedStorage.CS.GetPartyList:InvokeServer()
	print('PARTY LIST IS SAVED')
	local ts = os.date('%Y-%m-%dT%H:%M:%SZ')
	for _, d in next, list do
		local id = d.psid
		d.updated = ts
		data[id] = d
	end
	writefile(fn, game.HttpService:JSONEncode(data))
until not task.wait(666)

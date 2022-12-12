--[==[HELP]==
[1] - number | nil
	The place ID to evaluate.  If nil, the ID of the current place.

[2] - boolean | nil
	Sort in ascending player-count order if true; descending otherwise.
]==] --
--
local args = _E and _E.ARGS or {}
local function get_servers(place, limit, order)
	local place = place or game.PlaceId
	local order = order and 'Asc' or 'Desc'
	local servers = {}
	local cursor = ''
	local count = 0
	repeat
		local r = game:HttpGet(
			string.format(
				'https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100&cursor=%s',
					place, order, cursor))
		local iters = {
			id = string.gmatch(r, '"id":"(........%-....%-....%-....%-............)"'),
			playing = string.gmatch(r, '"playing":(%d+)'),
		}
		local function iter(...)
			local ret = {}
			for i, f in next, iters do
				local r = f(...)
				if not r then return nil end
				ret[i] = r
			end
			return ret
		end
		for m in iter do
			count = count + 1
			table.insert(servers, m)
			if count == limit then return servers end
		end
		cursor = string.match(r, '"nextPageCursor":"([^,]+)"')
	until not cursor
	return servers
end

return get_servers(unpack(args))

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
	local c = ''
	local t = {}
	local l = 0
	repeat
		local r = game:HttpGet(
			string.format(
				'https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100&cursor=%s',
					place, order, c))
		for m in string.gmatch(r, '"id":"(........%-....%-....%-....%-............)"') do
			l = l + 1
			table.insert(t, m)
			if l == limit then return t end
		end
		c = string.match(r, '"nextPageCursor":"([^,]+)"')
	until not c
	return t
end

_E.RETURN = {get_servers(unpack(args))}

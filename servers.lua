--[==[HELP]==
[1] - number | nil
	The place ID to evaluate.  If nil, the ID of the current place.

[2] - boolean | nil
	Sort in ascending player-count order if true; descending otherwise.

[3] - (s:string)->() | false | nil
	The output function; default is 'print'.  If false, suppress output.
]==] --
--
local args = _G.EXEC_ARGS or {}
local output = args[3] == nil and print or args[3] or function() end

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
			output(m)
			table.insert(t, m)
			if l == limit then return t end
		end
		c = string.match(r, '"nextPageCursor":"([^,]+)"')
	until not c
	return t
end

local result = get_servers(unpack(args))
_G.EXEC_RETURN = {result}

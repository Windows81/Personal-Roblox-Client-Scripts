local args = _G.EXEC_ARGS or {}

local function get_servers(limit, order)
	local order = order and 'Asc' or 'Desc'
	local c = ''
	local t = {}
	local l = 0
	repeat
		local r = game:HttpGet(
			string.format(
				'https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100&cursor=%s',
					game.PlaceId, order, c))
		for m in string.gmatch(r, '"id":"(........%-....%-....%-....%-............)"') do
			l = l + 1
			table.insert(t, m)
			if l == limit then return t end
		end
		c = string.match(r, '"nextPageCursor":"([^,]+)"')
	until not c
	return t
end

-- Optional Boolean argument determines if same server shall be rejoined.
if typeof(args[1]) == 'string' then
	game:GetService 'TeleportService':TeleportToPlaceInstance(
		game.PlaceId, args[1])
elseif typeof(args[1]) == 'number' then
	if args[1] < 1818 then
		local sId = get_servers(unpack(args))[args[1]]
		game:GetService 'TeleportService':TeleportToPlaceInstance(game.PlaceId, sId)
	elseif typeof(args[2]) == 'string' then
		game:GetService 'TeleportService':TeleportToPlaceInstance(args[1], args[2])
	elseif typeof(args[2]) == 'number' then
		local sId = get_servers(args[2], args[3])[args[2]]
		game:GetService 'TeleportService':TeleportToPlaceInstance(args[1], sId)
	else
		game:GetService 'TeleportService':Teleport(args[1])
	end
elseif args[1] ~= false then
	game:GetService 'TeleportService':TeleportToPlaceInstance(
		game.PlaceId, game.JobId)
else
	game:GetService 'TeleportService':Teleport(game.PlaceId)
end

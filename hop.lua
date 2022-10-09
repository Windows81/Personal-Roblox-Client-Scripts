local pId = game.PlaceId
local sId = game.JobId
local tFn = string.format('place/%011d-hop.txt', pId)
local sFn = string.format('place/%011d-hop.lua', pId)
local ts = game:GetService 'TeleportService'

local SKIP_ERRORS = {
	[Enum.TeleportResult.GameEnded] = true,
	[Enum.TeleportResult.Unauthorized] = true,
	[Enum.TeleportResult.GameNotFound] = true,
	[Enum.TeleportResult.Failure] = true,
}

local WAIT_ERRORS = {
	[Enum.TeleportResult.GameFull] = true,
	[Enum.TeleportResult.Flooded] = true,
}

-- Return nil/false to stop processing, anything else to save as stat and skip to next server.
local function get_stat()
	task.wait(69)
	local f = game.CoreGui.RobloxGui.SettingsShield. --
	SettingsShield.MenuContainer.PageViewClipper.PageView. --
	PageViewInnerFrame:findFirstChild 'Players'
	if not f then return false end
	local c = 0
	for _, g in next, f:GetDescendants() do
		if g.Name == 'MuteStatusButton' then
			if not g.MuteStatusImageLabel.Image:find '/Muted' then
				c = c + 1
				if c == 2 then return false end
			end
		end
	end
	return true
end

-- The script at file "sFn" should return a function.
if isfile(sFn) then get_stat = loadfile(sFn)() end

local function get_servers(limit)
	local c = ''
	local t = {0}
	local l = 0
	repeat
		local r = game:HttpGet(
			string.format(
				'https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100&cursor=%s',
					pId, c))
		for m in string.gmatch(r, '"id":"(........%-....%-....%-....%-............)"') do
			if m ~= sId then
				l = l + 1
				table.insert(t, m)
				table.insert(t, '')
			end
			if limit and l == limit then
				table.insert(t, sId)
				table.insert(t, '')
				t[1] = l * 2
				return t
			end
		end
		c = string.match(r, '"nextPageCursor":"([^,]+)"')
	until not c
	table.insert(t, sId)
	table.insert(t, '')
	t[1] = l * 2
	return t
end

local function get_saved_stats(lines)
	local t = {}
	for i = lines[1] + 2, #lines, 2 do
		local k, v = lines[i + 0], lines[i + 1]
		t[k] = tonumber(v) or v
	end
	return t
end

local function process_lines(lines)
	if not lines then return end
	local i = lines[1] + 0
	local s = lines[i]
	_G.lines = lines
	if s == sId then
		local v = get_stat()
		if v then
			lines[i + 1] = tostring(v)
			i = i - 2
			lines[1] = i
			s = lines[i]
		else
			s = nil
		end
	else
		s = nil
	end
	if s then
		while s do
			writefile(tFn, table.concat(lines, '\n'))
			ts:TeleportToPlaceInstance(pId, s)
			local _, r = ts.TeleportInitFailed:Wait()
			while r == Enum.TeleportResult.IsTeleporting do
				_, r = ts.TeleportInitFailed:Wait()
			end

			if WAIT_ERRORS[r] then
				task.wait(13)
			elseif SKIP_ERRORS[r] then
				table.remove(lines, i)
				table.remove(lines, i)
				i = i - 2
				lines[1] = i
				task.wait(2)
			end
		end
	else
		delfile(tFn)
	end
end

local lines
if isfile(tFn) then
	lines = readfile(tFn):split('\n')
elseif _E.ARGS then
	lines = get_servers()
end
process_lines(lines)

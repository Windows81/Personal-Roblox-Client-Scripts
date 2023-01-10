if not _E then error'This script requires Rsexec to run properly.' end

local p_id = game.PlaceId
local s_id = game.JobId
local t_fn = string.format('place/%011d-hop.txt', p_id)
local s_fn = string.format('place/%011d-hop.lua', p_id)
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

-- Return nil/false to stop processing, anything else to stringify and save as stat and skip to next server.
local function get_stat()
	task.wait(7)
	local f = game.CoreGui.RobloxGui.SettingsShield. --
	SettingsShield.MenuContainer.PageViewClipper.PageView. --
	PageViewInnerFrame:FindFirstChild 'Players'
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

-- The script at file "s_fn" should return a function.
if isfile(s_fn) then get_stat = loadfile(s_fn)() end

-- #region patch servers.lua

local function get_servers(place, limit, order)
	local place = place or game.PlaceId
	local order = order and 'Asc' or 'Desc'
	local servers = {}
	local cursor = ''
	local count = 0
	repeat
		local req = game:HttpGet(
			string.format(
				'https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100&cursor=%s',
					place, order, cursor))
		local iters = {
			id = string.gmatch(req, '"id":"(........%-....%-....%-....%-............)"'),
			playing = string.gmatch(req, '"playing":(%d+)'),
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
		cursor = string.match(req, '"nextPageCursor":"([^,]+)"')
	until not cursor
	return servers
end

-- #endregion patch

local function parse(lines)
	local t = {}
	for i = lines[1] + 2, #lines, 2 do
		local k, v = lines[i + 0], lines[i + 1]
		t[k] = tonumber(v) or v
	end
	return t
end

local function process_lines(lines)
	if not lines then return false end
	_G.lines = lines

	local i = tonumber(lines[1])
	local function set_i(n) i, lines[1] = n, n end

	if i == 2 then return true end
	if lines[i] ~= s_id then return true end

	local stat = get_stat()
	if not stat then return true end
	lines[i + 1] = tostring(stat)
	set_i(i - 2)

	while i >= 2 do
		writefile(t_fn, table.concat(lines, '\n'))
		ts:TeleportToPlaceInstance(p_id, lines[i])

		local _, r = ts.TeleportInitFailed:Wait()
		while r == Enum.TeleportResult.IsTeleporting do
			_, r = ts.TeleportInitFailed:Wait()
		end

		if SKIP_ERRORS[r] then
			table.move(lines, i + 2, #lines + 2, i)
			set_i(i - 2)
			task.wait(2)

		elseif WAIT_ERRORS[r] then
			if i == 2 then
				task.wait(13)
			else
				local temp = {}
				table.move(lines, i, i + 1, 1, temp)
				table.move(lines, i + 2, #lines + 2, i)
				table.move(temp, 1, 2, 2, lines)
			end
		end
	end

	return true
end

-- This script is called once Rsexec is started.
-- By using the _E.AUTO flag, we can rest easy knowing the routine won't run automatically.
local auto_run = _E.AUTO

local lines
if isfile(t_fn) then
	lines = readfile(t_fn):split('\n')

elseif not auto_run then
	lines = {0}
	local i = 0
	for _, t in next, get_servers(p_id) do
		if t.id ~= s_id then
			i = i + 1
			table.insert(lines, t.id)
			table.insert(lines, '')
		end
	end
	table.insert(lines, s_id)
	table.insert(lines, '')
	lines[1] = i * 2 + 2
end

if not lines then return end
assert(process_lines(lines))

local parsed = parse(lines)
if not auto_run then return parsed end

-- Dirty hack to let Rsexec know to accept normal input now.
print(parsed)
_E.EXEC('output', parsed)
_E.EXEC('output', '\0')
print(6)

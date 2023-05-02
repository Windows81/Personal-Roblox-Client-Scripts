--[==[HELP]==
Returns a list of players IDs and names in the current server.

[1] - bool | nil
	If true, returns verbose output.
	This does not affect the actual result - only the output.
]==] --
local VERBOSE = _E and _E.ARGS[1]
local pl_service = game:GetService 'Players'
local lp = pl_service.LocalPlayer
local result = {}
local lines = {}

local players = pl_service:GetPlayers()
table.sort(players, function(a, b) return a.UserId < b.UserId end)

for _, pl in next, players do
	local d_name = pl.DisplayName
	local u_name = pl.Name
	local id = pl.UserId
	local age = pl.AccountAge
	local ansi = pl == lp and '\x1b[32m' or '\x1b[00m'

	local d_str
	if d_name ~= u_name then
		d_str = string.format('\x1b[36m {%s}', d_name)
	else
		d_str = ''
	end

	local a_str
	if age ~= 1 then
		a_str = string.format('%d days', age)
	else
		a_str = '1 day'
	end

	local t_ln
	if pl.Team then t_ln = string.format('\x1b[90m[TEAM] \x1b[00m%s', pl.Team.Name) end

	local o
	if VERBOSE then
		o = table.concat(
			{ --
				string.format('\x1b[90m[NAME] %s%s%s', ansi, u_name, d_str),
				string.format('\x1b[90m  [ID] %s%d', ansi, id),
				string.format('\x1b[90m [AGE] %s', a_str),
				string.format('\x1b[90m[MEMB] %s', pl.MembershipType.Name),
				t_ln,
			}, '\n')
	else
		o = table.concat(
			{ --
				string.format('\x1b[90m[NAME] %s%s%s', ansi, u_name, d_str),
				string.format('\x1b[90m [ID]  \x1b[00m%d', id),
				t_ln,
			}, '\n')
	end
	table.insert(lines, o)
	table.insert(result, pl)
end

_E.OUTPUT = {table.concat(lines, '\n\n')}
return result

--[==[HELP]==
Returns a list of players IDs and names in the current server.
]==] --
local players = game:GetService 'Players'
local format = '\x1b[90m[NAME] %s%s%s\n\x1b[90m [ID]  \x1b[00m%d'
local disp_f = '\x1b[36m {%s}'
local lp = players.LocalPlayer
local result = {}
local lines = {}

local players = game.Players:GetPlayers()
table.sort(players, function(a, b) return a.UserId > b.UserId end)
for _, pl in next, players do
	local d_name = pl.DisplayName
	local u_name = pl.Name
	local id = pl.UserId
	local ansi = pl == lp and '\x1b[32m' or '\x1b[00m'
	local d_str = ''
	if d_name ~= u_name then d_str = string.format(disp_f, d_name) end
	table.insert(lines, string.format(format, ansi, u_name, d_str, id))
	table.insert(result, pl)
end

_E.OUTPUT = {table.concat(lines, '\n\n')}
return result

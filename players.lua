--[==[HELP]==
Returns a list of players IDs and names in the current server.
]==] --
local players = game:GetService 'Players'
local format = '\x1b[90m[NAME] %s%s\n\x1b[90m [ID]  \x1b[00m%d'
local lp = players.LocalPlayer
local result = {}
local lines = {}

for _, pl in next, players:GetPlayers() do
	local name = pl.Name
	local id = pl.UserId
	local ansi = pl == lp and '\x1b[32m' or '\x1b[00m'
	table.insert(lines, string.format(format, ansi, name, id))
	table.insert(result, pl)
end

_E.OUTPUT = {table.concat(lines, '\n\n')}
return result

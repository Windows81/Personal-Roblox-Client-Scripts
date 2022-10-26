--[==[HELP]==
Returns a list of place IDs and names for the current universe.
]==] --
local pages = game:GetService 'AssetService':GetGamePlacesAsync()
local format = '\x1b[90m[NAME] \x1b[00m%s\n\x1b[90m [ID] %s%11d'
local result = {}
local lines = {}

while true do
	for _, place_t in next, pages:GetCurrentPage() do
		local name = place_t.Name
		local id = place_t.PlaceId
		local ansi = id == game.PlaceId and '\x1b[32m' or '\x1b[00m'
		table.insert(lines, string.format(format, name, ansi, id))
		table.insert(result, place_t)
	end
	if pages.IsFinished then break end
	pages:AdvanceToNextPageAsync()
end

_E.OUTPUT = {table.concat(lines, '\n\n')}
_E.RETURN = {result}

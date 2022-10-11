--[==[HELP]==
Returns a list of place IDs and names for the current universe.
]==] --
local pages = game:GetService 'AssetService':GetGamePlacesAsync()
local format = '\x1b[90m[NAME] \x1b[00m%s\n\x1b[90m [ID] \x1b[00m%11d'
local result = {}
local lines = {}

while true do
	for _, place_t in pairs(pages:GetCurrentPage()) do
		table.insert(result, place_t)
		table.insert(lines, string.format(format, place_t.Name, place_t.PlaceId))
	end
	if pages.IsFinished then break end
	pages:AdvanceToNextPageAsync()
end

_E.OUTPUT = {table.concat(lines, '\n\n')}
_E.RETURN = {result}

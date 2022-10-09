--[==[HELP]==
Returns a list of place IDs and names for the current universe.
]==] --
local pages = game:GetService 'AssetService':GetGamePlacesAsync()
local result = {}
local lines = {}

while true do
	for _, place in pairs(pages:GetCurrentPage()) do
		table.insert(result, {name = place.Name, id = place.PlaceId})

		table.insert(lines, string.format('    Name: %s', place.Name))
		table.insert(lines, string.format('Place ID: %11d', place.PlaceId))
	end
	if pages.IsFinished then break end
	pages:AdvanceToNextPageAsync()
end

_E.OUTPUT = {table.concat(lines, '\n')}
_E.RETURN = {result}

--[==[HELP]==
[1] - (s:string)->() | false | nil
	The output function; default is 'print'.  If false, suppress output.
]==] --
local args = _G.EXEC_ARGS or {}
local output = args[1] == nil and print or args[1] or function() end
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

output(table.concat(lines, '\n'))
_G.EXEC_RETURN = {result}

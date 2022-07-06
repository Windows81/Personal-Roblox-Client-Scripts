local pages = game:GetService 'AssetService':GetGamePlacesAsync()
local result = {}
while true do
	for _, place in pairs(pages:GetCurrentPage()) do
		result[place.PlaceId] = place.Name
		print(string.format('    Name: %s', place.Name))
		print(string.format('Place ID: %11d', place.PlaceId))
	end
	if pages.IsFinished then break end
	pages:AdvanceToNextPageAsync()
end

_G.EXEC_RETURN = {result}

--[==[HELP]==
[1] - number | nil
	The place ID to teleport to, or in-universe index if <1818.
	If nil, default to the next place after current ID for in-universe index.
]==] --
local function teleport(id, instance)
	if instance then
		game:GetService 'TeleportService':TeleportToPlaceInstance(id, instance)
	else
		game:GetService 'TeleportService':Teleport(id)
	end
end

local args = _G.EXEC_ARGS or {}
local value = args[1]
if value < 1818 then
	local pages = game:GetService 'AssetService':GetGamePlacesAsync()
	while true do
		for _, place in next, pages:GetCurrentPage() do
			value = value - 1
			if value == 0 then
				teleport(place.PlaceId, unpack(args, 2))
				return
			end
		end
		if pages.IsFinished then break end
		pages:AdvanceToNextPageAsync()
	end

elseif value then
	teleport(value, unpack(args, 2))

else
	local pages = game:GetService 'AssetService':GetGamePlacesAsync()
	while true do
		local passedCurrent = false
		for _, place in next, pages:GetCurrentPage() do
			if game.PlaceId == place.PlaceId then
				passedCurrent = true
			elseif passedCurrent then
				teleport(place.PlaceId, unpack(args, 2))
				return
			end
		end
		if pages.IsFinished then break end
		pages:AdvanceToNextPageAsync()
	end
end

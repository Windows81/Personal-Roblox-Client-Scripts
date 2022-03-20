local args = _G.EXEC_ARGS or {}

-- Optional Boolean argument determines if same server shall be rejoined.
if args[1] ~= false then
	game:GetService 'TeleportService':TeleportToPlaceInstance(
		game.PlaceId, game.JobId)
else
	game:GetService 'TeleportService':Teleport(game.PlaceId)
end

local args = _G.EXEC_ARGS or {}

-- Optional Boolean argument determines if same server shall be rejoined.
if typeof(args[1]) == 'string' then
	game:GetService 'TeleportService':TeleportToPlaceInstance(
		game.PlaceId, args[1])
elseif typeof(args[1]) == 'number' then
	if args[2] then
		game:GetService 'TeleportService':TeleportToPlaceInstance(args[1], args[2])
	else
		game:GetService 'TeleportService':Teleport(args[1])
	end
elseif args[1] ~= false then
	game:GetService 'TeleportService':TeleportToPlaceInstance(
		game.PlaceId, game.JobId)
else
	game:GetService 'TeleportService':Teleport(game.PlaceId)
end

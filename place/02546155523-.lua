local args = _G.EXEC_ARGS
local COMMAND = args[1]:lower()

if COMMAND == 'party' then
	game.ReplicatedStorage.CS.JoinParty:FireServer(unpack(_G.EXEC_ARGS, 2))
elseif COMMAND == 'rename' then
	game.ReplicatedStorage.CS.ChangeN:FireServer(unpack(_G.EXEC_ARGS, 2))
end

--[==[HELP]==
[1] - string
	The command to execute.
]==] --
local args = _G.EXEC_ARGS or {}
local cmd = args[1]
game.ReplicatedStorage.HDAdminClient.Signals.RequestCommand:InvokeServer(cmd)

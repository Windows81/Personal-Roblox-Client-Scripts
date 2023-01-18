--[==[HELP]==
[1] - string
	The command to execute.
]==] --
local args = _E and _E.ARGS or {}
local cmd = args[1]

-- #region patch hd-cmd.lua
local rem = game.ReplicatedStorage.HDAdminClient.Signals.RequestCommand
function hd_cmd(cmd) rem:InvokeServer(cmd) end
-- #endregion patch
hd_cmd(cmd)

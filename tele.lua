--[==[HELP]==
[1] - CFrame | Vector3
	The location th teleport the player.
]==] --
--
local args = _G.EXEC_ARGS or {}
local CFRAME = args[1]
if typeof(CFRAME) == 'Vector3' then
	local ccp = game.Workspace.CurrentCamera.CFrame.Position
	CFRAME = CFrame.new(CFRAME, Vector3.nre(ccp.X, CFRAME.Y, ccp.Z))
else
	local rot = CFrame.new(Vector3.new(), CFRAME.LookVector * Vector3.new(1, 0, 1))
	CFRAME = rot + CFRAME.Position
end

game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFRAME)

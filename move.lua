--[==[HELP]==
[1] - Model | BasePart
	The object to move.

[2] - CFrame | Vector3
	The location to which to teleport the object.
]==] --
--
local args = _E and _E.ARGS or {}
local OBJECT = args[1]
local CFRAME = args[2]
if typeof(CFRAME) == 'Vector3' then
	local ccf = game.Workspace.CurrentCamera.CFrame
	CFRAME = CFrame.new(CFRAME, ccf.Position)
end

if not OBJECT then
	game.Players.LocalPlayer.Character:PivotTo(CFRAME)
elseif OBJECT:isA 'BasePart' then
	OBJECT.CFrame = CFRAME
elseif OBJECT:isA 'Model' then
	OBJECT:PivotTo(CFRAME)
end

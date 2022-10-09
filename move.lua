--[==[HELP]==
[1] - Model | BasePart
	The object to move.

[2] - CFrame | Vector3
	The location th teleport the object.
]==] --
--
local args = _E.ARGS
local OBJECT = args[1]
local CFRAME = args[2]
if typeof(CFRAME) == 'Vector3' then
	local ccf = game.Workspace.CurrentCamera.CFrame
	CFRAME = CFrame.new(CFRAME, ccf.Position)
end

if OBJECT:isA 'BasePart' then
	OBJECT.CFrame = CFRAME
elseif OBJECT:isA 'Model' then
	OBJECT:SetPrimaryPartCFrame(CFRAME)
end

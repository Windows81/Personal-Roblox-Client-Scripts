--[==[HELP]==
[1] - CFrame | Vector3 | Player | BasePart | Model | nil
	The location or object to teleport the player.
]==] --
--
local args = _E and _E.ARGS or {}
local VALUE = args[1]

local cf
local typ = typeof(VALUE)
if typ == 'Instance' then
	if VALUE:isA 'BasePart' then
		cf = VALUE.CFrame
	elseif VALUE:isA 'Model' then
		cf = VALUE:GetPivot()
	elseif VALUE:isA 'Player' then
		cf = VALUE.Character:GetPivot()
	end

elseif typ == 'Vector3' then
	local ccp = game.Workspace.CurrentCamera.CFrame.Position
	cf = CFrame.new(VALUE, Vector3.nre(ccp.X, VALUE.Y, ccp.Z))

elseif typ == 'CFrame' then
	cf = VALUE

else
	local rot = CFrame.new(Vector3.new(), VALUE.LookVector * Vector3.new(1, 0, 1))
	cf = rot + VALUE.Position
end

game.Players.LocalPlayer.Character:PivotTo(cf)

local args = _G.EXEC_ARGS or {}
local CFRAME = args[1]
if typeof(CFRAME) == 'Vector3' then
	local ccf = game.Workspace.CurrentCamera.CFrame
	CFRAME = CFrame.new(CFRAME, ccf.Position)
else
	local rot = CFrame.new(Vector3.new(), CFRAME.LookVector * Vector3.new(1, 0, 1))
	CFRAME = rot + CFRAME.Position
end

game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFRAME)

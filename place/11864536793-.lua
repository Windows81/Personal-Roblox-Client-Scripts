local lp = game.Players.LocalPlayer
local t_obj = game.Workspace.Time
local pos = Vector3.new(-558, -2300, 72)
t_obj.Changed:Connect(
	function() if t_obj.Value == 3 then lp.Character:MoveTo(pos) end end)

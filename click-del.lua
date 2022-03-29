local args = _G.EXEC_ARGS or {}
local m = game.Players.LocalPlayer:GetMouse()
if args[1] then
	wait(args[1])
else
	m.Button1Up:Wait()
end
m.Target:Destroy()

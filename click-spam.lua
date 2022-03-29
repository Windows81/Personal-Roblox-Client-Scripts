local args = _G.EXEC_ARGS or {}
if args[2] then
	wait(args[2])
else
	game.Players.LocalPlayer:GetMouse().Button1Up:Wait()
end

for _ = 1, args[1] or 307 do
	mouse1click()
	game:GetService 'RunService'.RenderStepped:Wait()
end

local args = _G.EXEC_ARGS or {}
wait(args[2] or 2)
for i = 1, args[1] or 307 do
	mouse1click()
	game:GetService 'RunService'.RenderStepped:Wait()
end

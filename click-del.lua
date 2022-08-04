local args = _G.EXEC_ARGS or {}
local m = game.Players.LocalPlayer:GetMouse()
local _ = args[1] and task.wait(args[1]) or m.Button1Up:Wait()
m.Target:Destroy()

local args = _G.EXEC_ARGS or {}
local m = game.Players.LocalPlayer:GetMouse()
local _ = args[1] and wait(args[1]) or m.Button1Up:Wait()
m.Target:Destroy()

local args = _G.EXEC_ARGS or {}
wait(args[1] or 2)
game.Players.LocalPlayer:GetMouse().Target:Destroy()

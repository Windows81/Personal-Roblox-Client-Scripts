--[==[HELP]==
To be used with "Kohaú Hibachi Restaurant".
]==] --
--
local o = game.Workspace.Spills.SpillStorage:GetChildren()[1]
print(_G.path_follow(o.Position))
local v = game.Workspace.CurrentCamera:WorldToScreenPoint(o.Position)
mousemoveabs(v.x, v.y + 50)
task.wait()
mouse1click()

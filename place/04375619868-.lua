local o = game.Workspace.Spills.SpillStorage:children()[1]
print(_G.path_follow(o.Position))
local v = game.Workspace.CurrentCamera:WorldToScreenPoint(o.Position)
mousemoveabs(v.x, v.y + 50)
task.wait()
mouse1click()

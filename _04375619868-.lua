local o = game.workspace.Spills.SpillStorage:children()[1]
print(_G.path_follow(o.Position))
local v = game.workspace.CurrentCamera:WorldToScreenPoint(o.Position)
mousemoveabs(v.x, v.y + 50)
wait()
mouse1click()

function f()
wait(1)
local h=game.Players.LocalPlayer.Character.Humanoid
h.WalkSpeed=30
for i=1,#_G.sqge do
while not _G.sqgv[i]do wait(2) end
h:MoveTo(_G.sqgv[i].Position)
h.Jump=true
if i==1 then
h.MoveToFinished:Wait()
end
wait(.8)
end
end
if _G.chl then _G.chl:Disconnect()end
_G.chl=game.Players.LocalPlayer.CharacterAdded:connect(f)
f()
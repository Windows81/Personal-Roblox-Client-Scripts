--_G.bg=_G.bg.Parent and _G.bg or Instance.new('BodyGyro',game.Players.LocalPlayer.Character.HumanoidRootPart)
--_G.bv=_G.bv.Parent and _G.bv or Instance.new('BodyVelocity',game.Players.LocalPlayer.Character.HumanoidRootPart)
_G.bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
_G.bv.MaxForce=Vector3.new(1e9,1e9,1e9)
_G.bv.P=1e7

for i,g in next,game.workspace:GetDescendants()do if g:isA'BasePart'then g.CanCollide=false end end
--_G.bg=Instance.new('BodyGyro',game.Players.LocalPlayer.Character.HumanoidRootPart)
_G.bv.Velocity=Vector3.new(0,0,0)
_G.bg.CFrame=CFrame.Angles(0,-math.pi/2,0)
--_G.bg.CFrame=CFrame.Angles(0,math.pi/2,0)
--_G.bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
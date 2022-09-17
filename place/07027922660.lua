-- _G.fp_bg=_G.fp_bg.Parent and _G.fp_bg or Instance.new('BodyGyro',game.Players.LocalPlayer.Character.HumanoidRootPart)
-- _G.fp_bv=_G.fp_bv.Parent and _G.fp_bv or Instance.new('BodyVelocity',game.Players.LocalPlayer.Character.HumanoidRootPart)
_G.fp_bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
_G.fp_bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
_G.fp_bv.P = 1e7

for i, g in next, game.Workspace:GetDescendants() do
	if g:isA 'BasePart' then g.CanCollide = false end
end
-- _G.fp_bg=Instance.new('BodyGyro',game.Players.LocalPlayer.Character.HumanoidRootPart)
_G.fp_bv.Velocity = Vector3.new(0, 0, 0)
_G.fp_bg.CFrame = CFrame.Angles(0, -math.pi / 2, 0)
-- _G.fp_bg.CFrame=CFrame.Angles(0,math.pi/2,0)
-- _G.fp_bg.MaxTorque=Vector3.new(1e9,1e9,1e9)

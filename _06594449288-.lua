wait(2)
local h = {}
for _, g in next, game.workspace.ShootingTargets:children() do
	local p = g:findFirstChild 'PrimaryPart'
	if p then h[p] = true end
end

local cc = game.workspace.CurrentCamera
local pl = game.Players.LocalPlayer

_G.aa_loop = tick()
local t = _G.aa_loop
local rs = game:GetService 'RunService'
while next(h) and _G.aa_loop == t do
	local ch = pl.Character.HumanoidRootPart.CFrame
	for p in next, h do
		local c = -ch:PointToObjectSpace(p.Position)
		if c.Z > 0 and c.Z < 9 and math.abs(c.X) / c.Z < 1.5 then
			local v, i = cc:WorldToViewportPoint(p.Position)
			local s = cc.ViewportSize
			if v.X > 0 and v.X < s.X and v.Y > 0 and v.Y < s.Y then
				local x, y = v.X, v.Y
				print(c, v, x, y)
				mousemoveabs(x, y)
				rs.Heartbeat:Wait()
				mouse1click()
				wait(.3)
				h[p] = nil
				break
			end
		end
	end
	rs.Heartbeat:Wait()
end

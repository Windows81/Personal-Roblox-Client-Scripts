local pl = game.Players.LocalPlayer
local key = Enum.KeyCode.T
local mouse = pl:GetMouse()

if _G.tp_ev then _G.tp_ev:Disconnect() end
_G.tp_ev = game:GetService 'UserInputService'.InputBegan:Connect(
	function(i, pr)
		local ch = pl.Character
		if pr or not ch then return end
		if i.KeyCode == key then
			local bl = {}
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Whitelist
			for _, o in next, game.workspace:GetDescendants() do
				if o:isA 'BasePart' and o.Transparency < 1 and not o:IsDescendantOf(ch) then
					table.insert(bl, o)
				end
			end
			local r = mouse.UnitRay
			rp.FilterDescendantsInstances = bl
			local res = game.workspace:Raycast(r.Origin, r.Direction * 5e3, rp)
			if not res then return end

			local n = res.Normal.Unit
			local d
			if n.Y > .25 then
				local h = ch:FindFirstChildWhichIsA 'Humanoid'
				d = h and h.HipHeight or 0
				if d == 0 then d = 5 end
			else
				local rp2 = RaycastParams.new()
				rp2.FilterType = Enum.RaycastFilterType.Whitelist
				rp2.FilterDescendantsInstances = {res.Instance}
				local res2 = game.workspace:Raycast(
					r.Origin + r.Direction * 5e3, r.Direction * -5e3, rp2)
				if not res2 then
					d = -4
				else
					local m = (res2.Position - res.Position).Magnitude
					d = -math.min(m + 4, 127)
				end
			end
			local off = d * n
			ch:SetPrimaryPartCFrame(CFrame.new(res.Position + off))
		end
	end)

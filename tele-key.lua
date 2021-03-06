local pl = game.Players.LocalPlayer
local mouse = pl:GetMouse()

local args = _G.EXEC_ARGS or {}
local KEY = args[1] or Enum.KeyCode.T
local TOTAL_DIST = args[2] or 1e5
local DIST_PER_RAYCAST = args[3] or 5e3

if _G.tp_ev then _G.tp_ev:Disconnect() end
_G.tp_ev = game:GetService 'UserInputService'.InputBegan:Connect(
	function(i, pr)
		local ch = pl.Character
		if pr or not ch then return end
		if i.KeyCode ~= KEY then return end

		local bl = {}
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Whitelist
		for _, o in next, game.workspace:GetDescendants() do
			if o:isA 'BasePart' and o.Transparency < 1 and not o:IsDescendantOf(ch) then
				table.insert(bl, o)
			end
		end
		local r = mouse.UnitRay
		local orig = r.Origin
		local dir = r.Direction * 5e3

		for _ = 0, TOTAL_DIST, DIST_PER_RAYCAST do
			rp.FilterDescendantsInstances = bl
			local res = game.workspace:Raycast(orig, dir, rp)

			if res then
				local d
				local n = res.Normal.Unit
				if n.Y > .25 then
					local h = ch:FindFirstChildWhichIsA 'Humanoid'
					d = h and h.HipHeight or 0
					if d == 0 then d = 5 end
				else
					local rp2 = RaycastParams.new()
					rp2.FilterType = Enum.RaycastFilterType.Whitelist
					rp2.FilterDescendantsInstances = {res.Instance}
					local res2 = game.workspace:Raycast(orig + dir, -dir, rp2)
					if not res2 then
						d = -4
					else
						local m = (res2.Position - res.Position).Magnitude
						d = -math.min(m + 4, 127)
					end
				end

				local off = d * n
				local p = res.Position + off
				local lv = ch:GetPrimaryPartCFrame().LookVector
				ch:SetPrimaryPartCFrame(CFrame.new(p, p + lv))
				return
			end
			orig = orig + DIST_PER_RAYCAST * dir
		end
	end)

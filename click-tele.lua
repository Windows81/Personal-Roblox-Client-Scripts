local pl = game.Players.LocalPlayer
local mouse = pl:GetMouse()
local args = _G.EXEC_ARGS or {}

local KEY = args[1]
if not KEY then KEY = Enum.KeyCode.T end

local TOTAL_DIST = args[2] or 1e5
if not TOTAL_DIST then TOTAL_DIST = 1e5 end

local DIST_PER_RAYCAST = args[3]
if not DIST_PER_RAYCAST then DIST_PER_RAYCAST = 5e3 end

local ROTATE_BY_CAM = args[4]
if ROTATE_BY_CAM == nil then ROTATE_BY_CAM = true end

if _G.tp_ev then _G.tp_ev:Disconnect() end
_G.tp_ev = game:GetService 'UserInputService'.InputBegan:Connect(
	function(i, pr)
		local ch = pl.Character
		if pr or not ch then return end
		if i.KeyCode ~= KEY then return end

		local bl = {}
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Whitelist
		for _, o in next, game.Workspace:GetDescendants() do
			if o:isA 'BasePart' and o.Transparency < 1 and not o:IsDescendantOf(ch) then
				table.insert(bl, o)
			end
		end
		local r = mouse.UnitRay
		local orig = r.Origin
		local dir = r.Direction * DIST_PER_RAYCAST

		for _ = 0, TOTAL_DIST, DIST_PER_RAYCAST do
			rp.FilterDescendantsInstances = bl
			local res = game.Workspace:Raycast(orig, dir, rp)

			if res then
				local d
				local n = res.Normal.Unit
				if n.Y > 0.25 then
					local h = ch:FindFirstChildWhichIsA 'Humanoid'
					d = h and h.HipHeight or 0
					if d == 0 then d = 5 end
				else
					local rp2 = RaycastParams.new()
					rp2.FilterType = Enum.RaycastFilterType.Whitelist
					rp2.FilterDescendantsInstances = {res.Instance}
					local res2 = game.Workspace:Raycast(orig + dir, -dir, rp2)
					if not res2 then
						d = -4
					else
						local m = (res2.Position - res.Position).Magnitude
						d = -math.min(m + 4, 127)
					end
				end

				local off = d * n
				local p = res.Position + off

				local lv
				if ROTATE_BY_CAM then
					lv = game.Workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1)
				else
					lv = ch:GetPrimaryPartCFrame().LookVector
				end
				ch:SetPrimaryPartCFrame(CFrame.new(p, p + lv))
				return
			end
			orig = orig + DIST_PER_RAYCAST * dir
		end
	end)

local args = _E and _E.ARGS or {}
local cc = game.Workspace.CurrentCamera
if _G.vc_cam then
	_G.vc_cam:Disconnect()
	cc.CameraType = 'Custom'
	_G.vc_cam = nil
else
	local TIME = args[1] or 7
	function get_participants()
		local mc = game.CoreGui.RobloxGui.SettingsShield.SettingsShield.MenuContainer
		local f =
			mc.PageViewClipper.PageView.PageViewInnerFrame:findFirstChild 'Players'
		if not f then return {} end
		local t = {}
		for _, g in next, f:GetDescendants() do
			if g.Name == 'MuteStatusButton' and
				not g.MuteStatusImageLabel.Image:find '/Muted' then
				t[#t + 1] = game.Players[g.Parent.Parent.Name:sub(12)]
			end
		end
		return t
	end

	local a = {}
	local t = 0
	local i = 0
	local n = 0
	cc.CameraType = 'Scriptable'
	_G.vc_cam = game:GetService 'RunService'.RenderStepped:Connect(
		function(d)
			if t > TIME and game.CoreGui.RobloxGui.SettingsShield.SettingsShield.Visible then
				t = 0
			end
			if t == 0 then
				i = i + 1
				if i >= n then
					i = 0
					a = get_participants()
					n = #a
				end
			end
			local pl = a[i % #a + 1]
			local ch = pl and pl.Character
			if not ch then
				t = 0
				return
			end
			cc.CFrame = ch.Head.CFrame * CFrame.new(0, 1, 5)
			t = t + d
		end)

end

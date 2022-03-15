local uis = game:GetService("UserInputService")
local rns = game:GetService("RunService")
if _G.hiddenGuis then
	for g, e in next, _G.hiddenGuis do
		if typeof(g) == 'Instance' then g.Enabled = e end
	end
	uis.MouseIconEnabled = _G.hiddenGuis.icon
	_G.hiddenGuis = nil
else
	local t = {icon = uis.MouseIconEnabled}
	uis.MouseIconEnabled = false
	for _, g in next, game:GetDescendants() do
		if typeof(g) == 'Instance' and
			(g.ClassName == 'ScreenGui') then
			t[g] = g.Enabled
			g.Enabled = false
		end
	end
	rns:SetRobloxGuiFocused(false)
	_G.hiddenGuis = t
end

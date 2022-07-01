--[==[HELP]==
[1] - boolean | nil
	If boolean, whether to hide or show all GUI elements; defaults to toggle.
]==] --
--
local args = _G.EXEC_ARGS or {}
local MODE = args[1]
local uis = game:GetService 'UserInputService'
local rns = game:GetService 'RunService'
if _G.hiddenGuis then
	if MODE == true then return end
	for g, e in next, _G.hiddenGuis do
		if typeof(g) == 'Instance' then g.Enabled = e end
	end
	uis.MouseIconEnabled = _G.hiddenGuis.icon
	_G.hiddenGuis = nil
else
	if MODE == false then return end
	local t = {icon = uis.MouseIconEnabled}
	uis.MouseIconEnabled = false
	for _, g in next, game:GetDescendants() do
		if typeof(g) == 'Instance' and (g.ClassName == 'ScreenGui') then
			t[g] = g.Enabled
			g.Enabled = false
		end
	end
	rns:SetRobloxGuiFocused(false)
	_G.hiddenGuis = t
end

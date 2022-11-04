--[==[HELP]==
[1] - boolean | nil
	If boolean, whether to hide or show all GUI elements; defaults to toggle.
]==] --
--
local args = _E and _E.ARGS or {}
local MODE = args[1]
local uis = game:GetService 'UserInputService'
local rns = game:GetService 'RunService'

local function should_hide(o)
	if o.ClassName == 'BillboardGui' then
		local parent = o
		while parent do
			if parent:FindFirstChild 'Humanoid' then return true end
			if parent == game.Workspace then break end
			parent = parent.Parent
		end
		if not parent then return false end
		local size = o.AbsoluteSize
		return size.X >= 127 or size.Y >= 127

	elseif o.ClassName == 'ScreenGui' then
		return true
	end
	return false
end

local function hide()
	local t
	if _G.hgui_cache then
		t = _G.hgui_cache
	else
		t = {icon = uis.MouseIconEnabled}
	end
	uis.MouseIconEnabled = false
	for _, g in next, game:GetDescendants() do
		if typeof(g) == 'Instance' and not t[g] and should_hide(g) then
			t[g] = g.Enabled
			g.Enabled = false
		end
	end
	rns:SetRobloxGuiFocused(false)
	_G.hgui_cache = t
end

local function unhide()
	if not _G.hgui_cache then return end
	for g, e in next, _G.hgui_cache do
		if typeof(g) == 'Instance' then g.Enabled = e end
	end
	uis.MouseIconEnabled = _G.hgui_cache.icon
	_G.hgui_cache = nil
end

local function decide(m)
	if m == true then
		hide()
	elseif m == false then
		unhide()
	elseif _G.hgui_cache then
		unhide()
	else
		hide()
	end
end
decide(MODE)

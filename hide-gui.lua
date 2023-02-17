--[==[HELP]==
[1] - boolean | nil
	If boolean value, whether to hide or show all GUI elements; defaults to toggle.

[2] - boolean | nil
	If true, hides BillboardGuis on the character, as well as others which have a 'big enough' size.
]==] --
--
local args = _E and _E.ARGS or {}
local TOGGLE = args[1]
local ADVANCED = args[2]

local uis = game:GetService 'UserInputService'
local rns = game:GetService 'RunService'

local function hide_aux() --
	local cache = {icon = uis.MouseIconEnabled}
	uis.MouseIconEnabled = false
	rns:SetRobloxGuiFocused(false)
	return cache
end

local function show_aux(t) --
	uis.MouseIconEnabled = t.icon
end

local CLASSES = {
	GUI = {
		check = function(o)
			local cn = o.ClassName
			if cn == 'BillboardGui' then
				if not ADVANCED then return true, false end

				local parent = o
				while parent do
					if parent:FindFirstChild 'Humanoid' then return true, true end
					if parent == game.Workspace then return true, false end
					parent = parent.Parent
				end

				if not parent then return true, false end
				local size = o.AbsoluteSize
				if size.X >= 127 or size.Y >= 127 then
					return true, true
				else
					return true, false
				end

			elseif cn == 'ScreenGui' or cn == 'GuiMain' then
				return true, true
			end
			return false, false
		end,
		hide = function(o) --
			local e = o.Enabled
			o.Enabled = false
			return e
		end,
		show = function(o) --
			o.Enabled = true
		end,
	},
}

local function hide_obj(obj_cache, o)
	for class, funcs in CLASSES do
		local is_class, proceed = funcs.check(o)
		if is_class then
			local t = obj_cache[class]
			if t[o] then return end
			if proceed then
				t[o] = funcs.hide(o)
			else
				t[o] = funcs.show(o)
			end
			break
		end
	end
end

local function hide()
	local obj_cache = _G.hgui_cache or {}
	for class, _ in CLASSES do --
		obj_cache[class] = obj_cache[class] or {}
	end
	for _, o in next, game:GetDescendants() do hide_obj(obj_cache, o) end
	_G.hgui_cache = { --
		obj = obj_cache,
		aux = hide_aux(),
	}
end

local function unhide()
	local cache = _G.hgui_cache
	if not cache then return end
	for class, t in cache.obj do
		local cl_t = CLASSES[class]
		for o, e in next, t do
			if e then
				cl_t.show(o)
			else
				cl_t.hide(o)
			end
		end
	end
	show_aux(cache.aux)
	_G.hgui_cache = nil
end

local function decide_toggle(m)
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
decide_toggle(TOGGLE)

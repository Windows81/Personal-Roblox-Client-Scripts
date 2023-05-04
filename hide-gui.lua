--[==[HELP]==
[1] - boolean | nil
	If boolean value, whether to hide or show all GUI elements; defaults to toggle.

[2] - boolean | nil
	If true, hides BillboardGuis which have a 'big enough' size or are on the character.
]==] --
--
local args = _E and _E.ARGS or {}
local TOGGLE = args[1]
local ADVANCED = args[2]

local uis = game:GetService 'UserInputService'
local rns = game:GetService 'RunService'

local function hide_auxs(aux_cache) --
	local cache = aux_cache or {}
	if cache.icon == nil then
		cache.icon = uis.MouseIconEnabled
		uis.MouseIconEnabled = false
	end
	rns:SetRobloxGuiFocused(false)
	return cache
end

local function show_auxs(aux_cache) --
	uis.MouseIconEnabled = aux_cache.icon
	return {}
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
					if parent == game.Workspace then return true, true end
					parent = parent.Parent
				end

				if not parent then return true, false end
				local size = o.AbsoluteSize
				print(o:GetFullName())
				return true, true
				--[[
				if size.X >= 127 or size.Y >= 127 then
					return true, true
				else
					return true, false
				end
				]]

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
			local e = o.Enabled
			o.Enabled = true
			return e
		end,
	},
}

local function hide_objs(obj_cache)
	local obj_cache = obj_cache or {}
	for class, _ in CLASSES do --
		obj_cache[class] = obj_cache[class] or {}
	end
	for _, o in next, game:GetDescendants() do
		for class, funcs in CLASSES do
			local is_class, proceed = funcs.check(o)
			if is_class then
				local t = obj_cache[class]
				if t[o] ~= nil then return end
				if proceed then
					t[o] = funcs.hide(o)
				else
					t[o] = funcs.show(o)
				end
				break
			end
		end
	end
	return obj_cache
end

local function show_objs(obj_cache)
	for class, t in obj_cache do
		local cl_t = CLASSES[class]
		for o, e in next, t do if e then cl_t.show(o) end end
	end
	return {}
end

local function hide()
	local cache = _G.hgui_cache or {}
	_G.hgui_cache = { --
		obj = hide_objs(cache.obj),
		aux = hide_auxs(cache.aux),
	}
end

local function show()
	local cache = _G.hgui_cache
	if not cache then return end
	cache.obj = show_objs(cache.obj)
	cache.aux = show_auxs(cache.aux)
	_G.hgui_cache = nil
end

local function decide_toggle(m)
	if m == true then
		hide()
	elseif m == false then
		show()
	elseif _G.hgui_cache then
		show()
	else
		hide()
	end
end
decide_toggle(TOGGLE)

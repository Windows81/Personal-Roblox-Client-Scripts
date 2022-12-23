--[==[HELP]==
[1] - boolean | nil
	If boolean, whether to hide or show all GUI elements; defaults to toggle.
]==] --
--
local args = _E and _E.ARGS or {}
local TOGGLE = args[1]

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
            if o.ClassName == 'BillboardGui' then
                return true, false
                --[[
				local parent = o
				while parent do
					if parent:FindFirstChild 'Humanoid' then return true, true end
					if parent == game.Workspace then break end
					parent = parent.Parent
				end
				return true, false
				--[[
				if not parent then return false end
				local size = o.AbsoluteSize
				return true, size.X >= 127 or size.Y >= 127
				]]

            elseif o.ClassName == 'ScreenGui' then
                return true, true
            end
            return false, false
        end,
        hide = function(o) --
            local e = o.Enabled
            o.Enabled = false
            return e
        end,
        show = function(o, e) --
            o.Enabled = e
        end
    }
}

local function hide_obj(obj_cache, o)
    for class, funcs in CLASSES do
        local is_class, proceed = funcs.check(o)
        if is_class then
            local t = obj_cache[class]
            if t[o] then return end
            if proceed then t[o] = funcs.hide(o) end
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
        aux = hide_aux()
    }
end

local function unhide()
    local cache = _G.hgui_cache
    if not cache then return end
    for class, t in cache.obj do
        local show_f = CLASSES[class].show
        for o, e in next, t do show_f(o, e) end
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

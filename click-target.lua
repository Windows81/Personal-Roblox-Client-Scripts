local args = _G.EXEC_ARGS or {}

local function get_name(o) -- Returns proper string wrapping for instances
	local n = o.Name
	local f = '.%s'
	if #n == 0 or n:match('[^%w]+') or n:sub(1, 1):match('[^%a]') then f = '["%s"]' end
	return f:format(n)
end

local function get_full(o)
	local r = get_name(o)
	local p = o.Parent
	while p and p ~= game do
		r = get_name(p) .. r
		p = p.Parent
	end
	return (o:IsDescendantOf(game) and 'game' or 'NIL') .. r
end

local m = game.Players.LocalPlayer:GetMouse()
local _ = args[1] and wait(args[1]) or m.Button1Up:Wait()
print(get_full(m.Target))

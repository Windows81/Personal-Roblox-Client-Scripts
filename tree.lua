local args = _G.EXEC_ARGS or {}

local range = args[1] or game.Players.LocalPlayer:GetDescendants()
local query = args[2] or function(o) return true end

local print_f = args[3] or print
local function get_name(o) -- Returns proper string wrapping for instances
	local n = o.Name
	local f = '.%s'
	if #n == 0 or n:match('[^%w]+') or n:sub(1, 1):match('[^%a]') then f = '["%s"]' end
	return f:format(n)
end

local function get_full(o)
	local r = get_name(o)
	local p = o.Parent
	local c = 1
	while p and p ~= game do
		r = get_name(p) .. r
		p = p.Parent
		c = c + 1
	end
	return (o:IsDescendantOf(game) and 'game' or 'NIL') .. r, c
end

for i, g in next, range do
	if query(g) then
		local n, c = get_full(g)
		print_f(('[%02d] %s {%s}\n'):format(c, n, g.ClassName))
	end
end
print_f('\n\n')

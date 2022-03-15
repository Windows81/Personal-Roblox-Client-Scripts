local print_f = print

local function query(o)
	--
	return o.ClassName:find 'Value'
end

local function range()
	--
	return game.Players.LocalPlayer:GetDescendants()
end

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

for i, g in next, range() do
	if query(g) then
		local n, c = get_full(g)
		print_f(('[%02d] %s {%s}\n'):format(c, n, g.ClassName))
	end
end
print_f('\n\n')

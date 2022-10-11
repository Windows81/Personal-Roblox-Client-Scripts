--[==[HELP]==
Traverses through a list of objects, with the full path and number of layers from the datamodel printed out.

[1] - {Instance} | Instance | nil
	List of objects to be traversed.

[2] - (Instance)->bool | nil
	Query function that, when returns true, proceeds with output; defaults to always-true.
]==] --
--
local lines = {}
local args = _E and _E.ARGS or {}
local range = args[1] or game
if typeof(range) == 'Instance' then range = range:GetDescendants() end
local query = args[2] or function(o) return true end

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

local t = {}
for _, g in next, range do
	local s, b = pcall(query, g)
	if s and b then
		local n, c = get_full(g)
		table.insert(
			lines, ('\x1b[92m[%02d] \x1b[00m%s \x1b[90m{%s}'):format(c, n, g.ClassName))
		table.insert(t, g)
	end
end

-- Printing line-by-line is necessary since the dev console truncates large outputs.
_E.OUTPUT = {table.concat(lines, '\n')}
_E.RETURN = {t}

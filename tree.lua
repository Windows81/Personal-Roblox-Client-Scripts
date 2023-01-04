--[==[HELP]==
Traverses through a list of Instance objects, with the full path and number of layers from the datamodel printed out.

[1] - {Instance} | Instance | nil
	List of objects to be traversed.
	If passed as a single instance, all its descendants are included in the range.

[2] - (Instance)->bool | nil
	Query function which, when returns true, adds the instance to the result table.
	Defaults to always-true.
]==] --
--
local args = _E and _E.ARGS or {}
local RANGE = args[1] or game
if typeof(RANGE) == 'Instance' then RANGE = RANGE:GetDescendants() end
local QUERY = args[2] or function(o) return true end

-- Returns proper string wrapping for instances.
local function get_name(o)
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
local lines = {}
for _, g in next, RANGE do
	local s, b = pcall(QUERY, g)
	if s and b then
		local n, c = get_full(g)
		table.insert(
			lines, ('\x1b[92m[%02d] \x1b[00m%s \x1b[90m{%s}'):format(c, n, g.ClassName))
		table.insert(t, g)
	end
end

-- Printing line-by-line is necessary since the dev console truncates large outputs.
_E.OUTPUT = {table.concat(lines, '\n')}
return t

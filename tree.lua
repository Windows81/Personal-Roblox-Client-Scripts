--[==[HELP]==
Traverses through a list of objects, with the full path and number of layers from the datamodel printed out.

[1] - {Instance} | Instance | nil
	List of objects to be traversed.

[2] - (Instance)->bool | nil
	Query function that, when returns true, proceeds with output; defaults to always-true.

[3] - (s:string)->() | false | nil
	The output function; default is 'print'.  If false, suppress output.
]==] --
--
local lines = {}
local args = _G.EXEC_ARGS or {}
local range = args[1] or game
if typeof(range) == 'Instance' then range = range:GetDescendants() end
local query = args[2] or function(o) return true end

local output = args[3] == nil and print or args[3] or function() end
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
		table.insert(lines, ('[%02d] %s {%s}'):format(c, n, g.ClassName))
		table.insert(t, g)
	end
end

-- Printing line-by-line is necessary since the dev console truncates large outputs.
if output == print then
	for _, l in next, lines do output(l) end
else
	output(table.concat(lines, '\n'))
end
_G.EXEC_RETURN = {t}

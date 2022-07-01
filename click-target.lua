--[==[HELP]==
[1] - number | nil
	The number of seconds to wait before the object path is printed; defaults to wait until next click.

[2] - (s:string|Instance)->() | nil
	An output function with the full path of the object passed in; default is 'print'.

[3] - boolean | nil
	If true or nil, passes the name of the instance into output(), otherwise the object itself.
]==] --
--
local args = _G.EXEC_ARGS or {}
local output = args[2] or print
local stringify = args[3] ~= false

local function get_name(o) -- Returns proper string wrapping for instances
	local n = o.Name
	local f = '.%s'
	if #n == 0 or n:match('[^%w]+') or n:sub(1, 1):match('[^%a]') then f = '["%s"]' end
	return f:format(n)
end

local function get_full(o)
	if not o then return nil end
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

local o = m.Target
local p = get_full(o)
_G.EXEC_RETURN = {o, p}

if stringify then
	output(tostring(p))
else
	output(p)
end

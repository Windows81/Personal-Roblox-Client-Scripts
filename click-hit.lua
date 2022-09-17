--[==[HELP]==
[1] - number | nil
	The number of seconds to task.wait before the CFrame hit location of the mouse is printed; defaults to task.wait until next click.

[2] - (s:string|CFrame)->() | false | nil
	An output function with the CFrame passed in; default is 'print'.  If false, suppress output.

[3] - boolean | nil
	If true or nil, passes the string representation of the CFrame into output(), otherwise the CFrame object itself.
]==] --
--
local args = _G.EXEC_ARGS or {}
local output = args[2] == nil and print or args[2] or function() end
local stringify = args[3] ~= false
local m = game.Players.LocalPlayer:GetMouse()
local _ = args[1] and task.wait(args[1]) or m.Button1Up:Wait()
local v = m.Hit
_G.EXEC_RETURN = {v}

if stringify then
	output(tostring(v))
else
	output(v)
end

--[==[HELP]==
[1] - number | nil
	The number of seconds to wait before the CFrame hit location of the mouse is printed; defaults to wait until next click.

[2] - (s:string|CFrame)->() | nil
	An output function with the CFrame passed in; default is 'print'.

[3] - boolean | nil
	If true or nil, passes the string representation of the CFrame into output(), otherwise the CFrame object itself.
]==] --
--
local args = _G.EXEC_ARGS or {}
local output = args[2] or print
local stringify = args[3] ~= false
local m = game.Players.LocalPlayer:GetMouse()
local _ = args[1] and wait(args[1]) or m.Button1Up:Wait()
local v = game.Workspace.CurrentCamera.CFrame
_G.EXEC_RETURN = {v}

if stringify then
	output(tostring(v))
else
	output(v)
end

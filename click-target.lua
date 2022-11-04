--[==[HELP]==
[1] - number | nil
	The number of seconds to task.wait before the object path is printed; defaults to task.wait until next click.
]==] --
--
local args = _E and _E.ARGS or {}
local m = game.Players.LocalPlayer:GetMouse()
local _ = args[1] and task.wait(args[1]) or m.Button1Up:Wait()

local o = m.Target
return o

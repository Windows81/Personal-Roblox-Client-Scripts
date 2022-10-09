--[==[HELP]==
[1] - number | nil
	The number of left-clicks that shall be done; default is 307.

[2] - number | nil
	The number of seconds to wait before spamming clicks; defaults to wait until next click.

[3] - number | nil
	The number of seconds to wait between clicks; defaults to RenderStepped:Wait().
]==] --
--
local args = _E and _E.ARGS or {}
if args[2] then
	task.wait(args[2])
else
	game.Players.LocalPlayer:GetMouse().Button1Up:Wait()
end

local rs = game:GetService 'RunService'.RenderStepped
local wait_f = args[3] and task.wait or rs.Wait
local wait_p = args[3] and args[3] or rs

for _ = 1, args[1] or 307 do
	mouse1click()
	wait_f(wait_p)
end

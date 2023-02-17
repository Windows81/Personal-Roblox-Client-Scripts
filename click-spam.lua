--[==[HELP]==
[1] - number | nil
	The number of left-clicks that shall be done; default is 307.

[2] - number | nil
	The number of seconds to wait between clicks; defaults to RenderStepped:Wait().

[3] - number | nil
	The number of seconds to wait before spamming clicks; defaults to wait until next click.
]==] --
--
local args = _E and _E.ARGS or {}
local TIMES = args[1] or 307
local WAIT_BR = args[2]
local WAIT_D = args[3]

-- #region patch click-wait.lua
local mouse = game.Players.LocalPlayer:GetMouse()
---@diagnostic disable-next-line: undefined-global
local _ = WAIT_D and task.wait(WAIT_D) or mouse.Button1Up:Wait()
-- #endregion patch
if args[3] then
	task.wait(args[3])
else
	game.Players.LocalPlayer:GetMouse().Button1Up:Wait()
end

local rs = game:GetService 'RunService'.RenderStepped
local wait_f = WAIT_BR and task.wait or rs.Wait
local wait_p = WAIT_BR and WAIT_BR or rs

for _ = 1, TIMES do
	mouse1click()
	wait_f(wait_p)
end

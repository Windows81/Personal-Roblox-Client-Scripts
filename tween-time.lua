--[==[HELP]==
Runs a RenderStepped loop that loops through the time of day over an arbitrary number of seconds.

[1] - number | nil
	Duration in seconds for each day/night cycle; defaults to 7.

[2] - number | nil
	Number of day/night cycles to take place; defaults to 1
]==] --
--
local args = _E and _E.ARGS or {}
local DURATION = args[1] or 7
local CYCLES = args[2] or 1

local rs = game:GetService 'RunService'
local l = game:GetService 'Lighting'
local stop = l.ClockTime + 24 * CYCLES
local t = l.ClockTime
if _G.time_l then _G.time_l:Disconnect() end
_G.time_l = rs.RenderStepped:Connect(
	function(d)
		if t > stop then _G.time_l:Disconnect() end
		t = t + 24 * d / DURATION
		l.ClockTime = t % 24
	end)

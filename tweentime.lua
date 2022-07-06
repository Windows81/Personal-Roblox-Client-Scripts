--[==[HELP]==
Traverses through a list of objects, with the full path and number of layers from the datamodel printed out.

[1] - number | nil
	Duration in seconds for each day/night cycle; defaults to 7.

[2] - number | nil
	Number of day/night cycles to take place; defaults to 1
]==] --
--
local args = _G.EXEC_ARGS or {}
local duration = args[1] or 7
local cycles = args[2] or 1
local rs = game:GetService 'RunService'
local l = game:GetService 'Lighting'
local stop = l.ClockTime + 24 * cycles
local t = l.ClockTime
if _G.time_l then _G.time_l:Disconnect() end
_G.time_l = rs.RenderStepped:Connect(
	function(d)
		if t > stop then _G.time_l:Disconnect() end
		t = t + 24 * d / duration
		l.ClockTime = t % 24
	end)

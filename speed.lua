--[==[HELP]==
Calculates the current velocity of the local character in studs per second.

[1] - number | nil
	The number of seconds between polls; defaults to ~1/30.

[2] - (s:string|number)->() | nil
	An output function with the speed passed in; default is 'print'.

[3] - boolean | nil
	If true or nil, passes a string containing the speed into output(), otherwise the numerical value itself.
]==] --
--
local args = _G.EXEC_ARGS or {}
local output = args[2] or print

local ch = game.Players.LocalPlayer.Character
if not ch then return end
local p = ch.PrimaryPart

local p1 = p.Position
local d = wait(args[1] or 0)
local p2 = p.Position

local v = (p2 - p1).Magnitude / d
_G.EXEC_RETURN = {v}

if stringify then
	output(tostring(p))
else
	output(p)
end
output(string.format('%.1f studs per second', v))

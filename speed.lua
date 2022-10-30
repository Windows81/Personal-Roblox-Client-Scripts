--[==[HELP]==
Calculates the current velocity of the local character in studs per second.

[1] - number | nil
	The number of seconds between polls; defaults to ~1/30.
]==] --
--
local args = _E and _E.ARGS or {}
local ch = game.Players.LocalPlayer.Character
if not ch then return end
local p = ch.PrimaryPart

local p1 = p.Position
local d = task.wait(args[1] or 0)
local p2 = p.Position

local VALUE = (p2 - p1).Magnitude / d
_E.RETURN = {VALUE}
_E.OUTPUT = {string.format('%.1f studs per second', VALUE)}

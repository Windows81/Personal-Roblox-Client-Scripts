--[==[HELP]==
Calculates the current velocity of the local character in studs per second.

[1] - number | nil
	The number of seconds between polls; defaults to ~1/30.
]==] --
--
local args = _G.EXEC_ARGS or {}
local ch = game.Players.LocalPlayer.Character
if not ch then return end
local p = ch.PrimaryPart

local p1 = p.Position
local d = task.wait(args[1] or 0)
local p2 = p.Position

local v = (p2 - p1).Magnitude / d
_G.EXEC_RETURN = {v}
_G.EXEC_OUTPUT = {p, string.format('%.1f studs per second', v)}

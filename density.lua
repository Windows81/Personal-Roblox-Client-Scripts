--[==[HELP]==
Taken from Infinite Yield's 'strengthen' command.
Makes current character more dense vía CustomPhysicalProperties.

[1] - number | bool | nil
	Sets the density property of each part to that value.
	If true, sets to 100.  If false or nil, sets to original density.
]==] --
--
local args = _E and _E.ARGS or {}
local DENSITY = args[1]
if DENSITY == nil or DENSITY == true then
	DENSITY = 100
elseif DENSITY == false then
	DENSITY = 0.7
end

local lp = game.Players.LocalPlayer
for _, p in next, lp.Character:GetDescendants() do
	if p.ClassName == 'Part' then
		p.CustomPhysicalProperties = PhysicalProperties.new(DENSITY, 0.3, 0.5)
	end
end

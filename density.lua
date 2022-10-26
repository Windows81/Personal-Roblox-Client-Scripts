-- Taken from Infinite Yield's 'strengthen' command.
local args = _E and _E.ARGS or {}
local DENSITY = args[1] or 100
local lp = game.workspace.Players.LocalPlayer

for _, p in next, lp.Character:GetDescendants() do
	if p.ClassName == 'Part' then
		p.CustomPhysicalProperties = PhysicalProperties.new(DENSITY, 0.3, 0.5)
	end
end

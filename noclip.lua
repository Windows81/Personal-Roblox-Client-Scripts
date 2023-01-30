--[==[HELP]==
Toggles disabling collisions for all objects in the datamodel.
Unlike other implementations of 'noclip', this script does NOT include flying tools.
Use your own fly script.

[1] - bool | nil
	Enabled noclipping if true; disables if false; toggles if nil.
]==] --
--
local args = _E and _E.ARGS or {}
_G.nc_cache = _G.nc_cache or {}

local TOGGLE = args[1]
if TOGGLE == nil then TOGGLE = #_G.nc_cache == 0 end

if TOGGLE then
	for _, p in next, game:GetDescendants() do
		if p:IsA 'BasePart' then
			if _G.nc_cache[p] == nil and p.CanCollide then
				p.CanCollide = false
				_G.nc_cache[p] = true
			end
		end
	end
else
	for p, _ in next, _G.nc_cache do p.CanCollide = true end
	_G.nc_cache = {}
end

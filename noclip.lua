local args = _G.EXEC_ARGS or {}
_G.nc_cache = _G.nc_cache or {}

local togg = #args > 0 and args[1] or not next(_G.nc_cache)
if togg then
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

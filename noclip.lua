local args = _G.EXEC_ARGS or {}
_G.nc_cache = _G.nc_cache or {}

local togg = #args > 0 and args[1] or not next(_G.nc_cache)
for _, p in next, game:GetDescendants() do
	if p:IsA 'BasePart' then
		if togg == (_G.nc_cache[p] == nil) then
			local c = p.CanCollide
			p.CanCollide = _G.nc_cache[p] or false
			_G.nc_cache[p] = togg and c or nil
		end
	end
end

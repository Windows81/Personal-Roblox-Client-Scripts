local rs = game:GetService 'RunService'
local o
o = hookmetamethod(
	rs, '__namecall', function(s, ...)
		local n = getnamecallmethod()
		if n == 'IsServer' then
			return true
		elseif n == 'IsClient' then
			return false
		end
		return o(s, ...)
	end)

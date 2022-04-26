local metatable = getrawmetatable(game)
setreadonly(metatable, false)

local nc = _G.pls_nc or metatable.__namecall
_G.pls_rmt = _G.pls_rmt or {}
_G.pls_nc = nc

function hex(c)
	return string.format('#%02X%02X%02X', 255 * c.r, 255 * c.g, 255 * c.b)
end

exec(
	'time', '%H:%M:%S', function(_, ts)
		local t = _G.pls_rmt
		if t.booth then
			local hh = hex(Color3.fromHSV(ts / 60 / 60 / 24 % 1, 1 / 2, 1))
			local mh = hex(Color3.fromHSV(ts / 60 / 60 / 01 % 1, 1 / 2, 1))
			local sh = hex(Color3.fromHSV(ts / 60 / 01 / 01 % 1, 1 / 2, 1))
			local f = [[<stroke thickness="5" joins="round">]] --
			.. [[<font face="Ubuntu">The time is<br/><b><font color="]] --
			.. hh .. [[">%H</font><font size="7"> </font>]] --
			.. [[:<font size="7"> </font><font color="]] --
			.. mh .. [[">%M</font><font size="7"> </font>]] --
			.. [[:<font size="7"> </font><font color="]] --
			.. sh .. [[">%S</font> UTC</b></font></stroke>]]
			t.booth:FireServer(os.date(f, ts), 'booth')
		end
	end, 5, 'pls')

metatable.__namecall = newcclosure(
	function(self, ...)
		local m = getnamecallmethod(self)
		if self and self.ClassName == 'RemoteEvent' and m == 'FireServer' then
			local t = _G.pls_rmt
			if not t.booth and select(2, ...) == 'booth' then t.booth = self end
		end
		local r = {nc(self, ...)}
		return unpack(r)
	end)
setreadonly(metatable, true)
print('FUNCTIONS HÒÓKED UP')

exec'fly'
exec'freecam'
-- exec'hide-all'

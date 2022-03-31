getgenv().exec = function(n, ...)
	local fs = {
		n,
		string.format('%s.lua', n),
		n == 'PLACE' and ('_%011d-.lua'):format(game.PlaceId),
		n == 'PLACE' and ('_%011d.lua'):format(game.PlaceId),
	}
	for _, f in next, fs do
		if f and isfile(f) then
			_G.EXEC_ARGS = {...}
			local s, e = pcall(loadfile(f))
			if not s then warn(e) end
			_G.EXEC_ARGS = nil
			break
		end
	end
end

for _, n in next, {
	'aafk.lua',
	'tele-key.lua',
	'log.lua',
	'zoom.lua',
	-- 'rspy.lua',
} do loadfile(n)() end

local n = ('_%011d.lua'):format(game.PlaceId)
if isfile(n) then print('LOADFILE FOR PLACE:', pcall(loadfile(n))) end

getgenv().exec = function(n, ...)
	local fs = {n, string.format('%s.lua', n)}
	if type(n) == 'number' then
		fs = {
			--
			('_%011d-.lua'):format(n),
			('_%011d.lua'):format(n),
		}
	elseif n == 'PLACE' then
		fs = {
			--
			('_%011d-.lua'):format(game.PlaceId),
			('_%011d.lua'):format(game.PlaceId),
		}
	elseif n == 'PLACE-' then
		fs = {
			--
			('_%011d-.lua'):format(game.PlaceId),
		}
	end

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
	'zoom-dist.lua',
	'click-dist.lua',
	'tele-key.lua',
	'auto-rej.lua',
	'log.lua',
	-- 'rspy.lua',
} do loadfile(n)() end

local n = ('_%011d.lua'):format(game.PlaceId)
if isfile(n) then print('LOADFILE FOR PLACE:', pcall(loadfile(n))) end

wait(5)
local function gsp(n, ...)
	local fs
	local l = n:lower()
	if type(n) == 'number' then
		fs = { --
			('place/%011d-.lua'):format(n),
			('place/%011d.lua'):format(n),
		}
	elseif n == 'PLACE' then
		fs = { --
			('place/%011d-.lua'):format(game.PlaceId),
			('place/%011d.lua'):format(game.PlaceId),
		}
	elseif n == 'PLACE-' then
		fs = { --
			('place/%011d-.lua'):format(game.PlaceId),
		}
	elseif l ~= n then
		fs = { --
			n,
			l,
			string.format('%s.lua', n),
			string.format('%s.lua', l),
		}
	else
		fs = { --
			n,
			string.format('%s.lua', n),
		}
	end
	for _, f in next, fs do if f and isfile(f) then return f end end
end

local function e(n, ...)
	local f = gsp(n, ...)
	if not f then warn(string.format('SCRIPT AT PATH "%s" DOES NOT EXISTS', n)) end
	_G.EXEC_ARGS = {...}
	local s, e = pcall(loadfile(f))
	if not s then warn(e) end
	local r = _G.EXEC_RETURN or {}
	_G.EXEC_RETURN = nil
	_G.EXEC_ARGS = nil
	return unpack(r)
end

getgenv().getscriptpath = gsp
getgenv().exec = e

for _, n in next, {
	-- 'input.lua',
	-- 'hop.lua',
	'aafk.lua',
	'zoom-dist.lua',
	'click-dist.lua',
	'tele-key.lua',
	-- 'auto-rej.lua',
	'log.lua',
	-- 'mute.lua',
	-- 'rspy.lua',
} do spawn(function() loadfile(n)() end) end

local n = ('_%011d.lua'):format(game.PlaceId)
if isfile(n) then print('LOADFILE FOR PLACE:', pcall(loadfile(n))) end

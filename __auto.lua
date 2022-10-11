--[[
	Have another script in your 'autoexec' directory execute this:
	loadfile'__auto.lua'()
]] --
--
-- Script paths that are automatically loaded once injected.
local SCRIPTS = { --
	-- 'input.lua',
	-- 'hop.lua',
	'aafk.lua',
	'zoom-dist.lua',
	'click-dist.lua',
	'tele-key.lua',
	-- 'auto-rej.lua',
	'event-log.lua',
	-- 'mute.lua',
	'rspy.lua',
}

-- Returns a list of paths to search given the command query.
local function gsps(n, ...)
	if type(n) == 'number' then
		return { --
			('place/%011d-.lua'):format(n),
			('place/%011d.lua'):format(n),
		}
	end

	local l = n:lower()
	local _, _, id, suffix = l:find('^([0-9]+)(.*)$')
	if not id then
		_, _, suffix = l:find('^place(.*)$')
		id = game.PlaceId
	end

	if suffix == '-' then
		return { --
			('place/%011d-.lua'):format(id),
			('place/%011d.lua'):format(id),
		}
	elseif suffix == '+' then
		return { --
			('place/%011d.lua'):format(id),
		}
	elseif suffix == '' then
		return { --
			('place/%011d-.lua'):format(id),
		}
	end

	if l ~= n then
		return { --
			string.format('%s.lua', n),
			string.format('%s.lua', l),
			n,
			l,
		}
	else
		return { --
			string.format('%s.lua', n),
			n,
		}
	end
end

local function gsp(n, ...)
	for _, f in next, gsps(n, ...) do if f and isfile(f) then return f end end
end

local NOT_FOUND_STRING = 'QUERY "%s" DID NOT YIELD ANY RESULTS'
local function exc(n, ...)
	local path = gsp(n, ...)
	if not path then error(string.format(NOT_FOUND_STRING, n)) end
	_E.ARGS = {...}
	_E.RETURN = nil
	_E.OUTPUT = nil
	loadfile(path)()
	local result = _E.RETURN or {}
	_E.ARGS = nil
	_E.RETURN = nil
	return unpack(result)
end

local function output(o)
	loadfile('save.lua')(_E.OUT_PATH, o, true)
	return o
end

local env = getrenv()
local BASE = { --
	rsexec = exc,
	getscriptpath = gsp,
	output = output,
}
local ALIASES = { --
	['E'] = 'RSEXEC',
	['GSP'] = 'GETSCRIPTPATH',
	['EXEC'] = 'RSEXEC',
	['A'] = 'ARGS',
	['R'] = 'RETURN',
	['O'] = 'OUTPUT',
}

local function get_meta_key(k)
	local l = k:upper()
	return ALIASES[l] or l
end

env._E = setmetatable(
	BASE, {
		__index = function(self, k) return rawget(self, get_meta_key(k)) end,
		__newindex = function(self, k, v) return rawset(self, get_meta_key(k), v) end,
		__call = function(self, ...) return exc(...) end,
	})

for _, n in next, SCRIPTS do task.spawn(function() loadfile(n)() end) end
local n = ('place/%011d.lua'):format(game.PlaceId)
if isfile(n) then print('LOADFILE FOR PLACE:', pcall(loadfile(n))) end

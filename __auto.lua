--[[
	Have another script in your 'autoexec' directory execute this:
	loadfile'__auto.lua'()
]] --
--
-- Script paths that are automatically loaded once injected.
local SCRIPTS = {
	-- 'input.lua',
	-- 'hop.lua',
	'aafk.lua',
	'zoom-dist.lua',
	'click-dist.lua',
	'click-tele.lua',
	-- 'auto-rej.lua',
	'event-log.lua',
	-- 'mute.lua',
	-- 'rspy.lua',
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

local function exc(n, ...)
	local path = gsp(n, ...)
	if not path then warn(string.format('QUERY "%s" DID NOT YIELD ANY RESULTS', n)) end
	_G.EXEC_ARGS = {...}
	local success, err_msg = pcall(loadfile(path))
	if not success then warn(err_msg) end
	local result = _G.EXEC_RETURN or {}
	_G.EXEC_RETURN = nil
	_G.EXEC_ARGS = nil
	return unpack(result)
end

local env = getrenv()
env.getscriptpath = gsp
env.rsexec = exc
env.E = exc

_G.EXEC_ARGS = {}
for _, n in next, SCRIPTS do task.spawn(function() loadfile(n)() end) end
local n = ('place/%011d.lua'):format(game.PlaceId)
if isfile(n) then print('LOADFILE FOR PLACE:', pcall(loadfile(n))) end

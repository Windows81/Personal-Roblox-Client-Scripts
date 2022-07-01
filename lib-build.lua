local args = _G.EXEC_ARGS
local env = getfenv()

local FUNCS = {}
local function load(i, s) FUNCS[s] = args[s] or env[s] or args[i] end
load(1, 'ADD_BLOCK')
load(2, 'BLOCK_EXISTS')
load(3, 'CLEAR_BLOCKS')
load(4, 'WAIT_FOR_BLOCK')
load(5, 'REMOVE_BLOCK')

_G.build_last_cleared = _G.build_last_cleared or tick()
_G.build_cache = _G.build_cache or {}
local function cache_key(cf)
	return string.format('%.1f %.1f %.1f', cf.x, cf.y, cf.z)
end

local function make(cfs, ...)
	if not _G.build_last_cleared then return false end
	local a = {...}
	local b = false
	local r = {}
	local c = 0
	local n = 0
	for i, cf in next, cfs do
		local s = cache_key(cf)
		if _G.build_cache[s] == nil then
			_G.build_cache[s] = false
			delay(
				i / 32 + 3 / 16, function()
					local o = FUNCS.ADD_BLOCK(cf, unpack(a))
					if o then
						_G.build_cache[cache_key(cf)] = o
						n = n + 1
						b = true
					end
				end)
			c = c + 1
		end
	end
	if c == 0 then return false end

	local cfh = {}
	for _, cf in next, cfs do cfh[cf] = true end

	local last = _G.build_last_cleared
	if FUNCS.WAIT_FOR_BLOCK then
		while n < c do
			b = true
			n = n + 1
			local ocf, o = FUNCS.WAIT_FOR_BLOCK()
			local min, mcf
			for cf in next, cfh do
				local d = ocf * cf:inverse()
				local v = d.Position.Magnitude + select(2, d:ToEulerAnglesYXZ())
				if not min or v < min then min, mcf = v, cf end
			end

			if _G.build_last_cleared ~= last then return false end
			_G.build_cache[cache_key(mcf)] = o
			cfh[mcf] = nil
			table.insert(r, o)
			print(n, c, mcf)
		end
	end
	return b, r
end

local function void(cfs)
	for _, cf in next, cfs do
		local s = cache_key(cf)
		if _G.build_cache[s] == nil then _G.build_cache[s] = false end
	end
end

local function delete(cfs)
	local b = false
	for _, cf in next, cfs do
		local s = cache_key(cf)
		local o = _G.build_cache[s]
		if o and o.Parent then b = b or FUNCS.REMOVE_BLOCK(o) end
		_G.build_cache[s] = nil
	end
	return b
end

local function reset()
	local b = true
	if FUNCS.CLEAR_BLOCKS then
		FUNCS.CLEAR_BLOCKS()
		for s, o in next, _G.build_cache do
			if FUNCS.BLOCK_EXISTS(o) then
				b = false
			else
				_G.build_cache[s] = nil
			end
		end
	else
		for s, o in next, _G.build_cache do
			if o and o.Parent and not FUNCS.REMOVE_BLOCK(o) then
				b = false
			else
				_G.build_cache[s] = nil
			end
		end
	end
	if b then
		_G.build_last_cleared = nil
		wait(1)
		_G.build_last_cleared = tick()
	end
	return b
end

-- Geneator that returns o box of CFrames of a 2D or 3D box.
local function box3(cf, x, y, z, d)
	local t = {}
	local i = 0
	for X = 0, x, x > 0 and 1 or -1 do
		for Y = 0, y, y > 0 and 1 or -1 do
			for Z = 0, z, z > 0 and 1 or -1 do
				i = i + 1
				t[i] = cf * CFrame.new(d * X, d * Y, d * Z)
			end
		end
	end
	return t
end

-- Generator that returns a single CFrame.
local function sngl(cf) return {cf} end

-- Geneator that returns CFrames arranged in a hollow 2D or 3D box.
local function frme(cf, x, y, z, d)
	local t = {}
	local i = 0
	for X = 0, x, x > 0 and 1 or -1 do
		for Y = 0, y, y > 0 and 1 or -1 do
			for Z = 0, z, z > 0 and 1 or -1 do
				local cX = (X == 0) ~= (x == X)
				local cY = (Y == 0) ~= (y == Y)
				local cZ = (Z == 0) ~= (z == Z)
				if cX or cY or cZ then
					i = i + 1
					t[i] = cf * CFrame.new(d * X, d * Y, d * Z)
				end
			end
		end
	end
	return t
end

-- Geneator that returns o box of CFrames of a 2D or 3D box minus the outer layer.
local function invf(cf, x, y, z, d)
	local t = {}
	local i = 0
	for X = 0, x, x > 0 and 1 or -1 do
		for Y = 0, y, y > 0 and 1 or -1 do
			for Z = 0, z, z > 0 and 1 or -1 do
				local cX = (X == 0) == (x == X)
				local cY = (Y == 0) == (y == Y)
				local cZ = (Z == 0) == (z == Z)
				if cX and cY and cZ then
					i = i + 1
					t[i] = cf * CFrame.new(d * X, d * Y, d * Z)
				end
			end
		end
	end
	return t
end

-- Generator that offsets an arbitrary parameter.
local function iter(f, num_calls, arg_num, arg_inc, ...)
	local r = {}
	local a = {...}
	local iscf = typeof(arg_inc) == 'CFrame'
	for _ = 1, num_calls do
		for _, cf in next, f(unpack(a)) do table.insert(r, cf) end
		if iscf then
			a[arg_num] = arg_inc * a[arg_num]
		else
			a[arg_num] = arg_inc + a[arg_num]
		end
	end
	return r
end

-- Join of two or more generators.
local function join(a)
	local r = {}
	for _, t in next, a do for _, cf in next, t do table.insert(r, cf) end end
	return r
end

env.make = make
env.void = void
env.delete = delete
env.reset = reset
env.box3 = box3
env.sngl = sngl
env.frme = frme
env.invf = invf
env.iter = iter
env.join = join

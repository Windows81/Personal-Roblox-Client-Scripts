local args = _G.EXEC_ARGS
local env = getfenv()
local evt = Instance.new'BindableEvent'

local FUNCS = {}
local function load(i, s, d) FUNCS[s] = args[s] or env[s] or args[i] or d end
load(1, 'ADD_BLOCK')
load(2, 'BLOCK_EXISTS')
load(3, 'CLEAR_BLOCKS')
load(4, 'WAIT_FOR_BLOCK')
load(5, 'REMOVE_BLOCK')
load(6, 'BLOCK_CHUNK_SIZE', -1)
load(7, 'BLOCK_CHUNK_PERIOD', 0)

_G.build_last_cleared = _G.build_last_cleared or tick()
_G.build_store = _G.build_store or {}
_G.build_cache = _G.build_cache or {}
_G.build_queue = _G.build_queue or {}
local function cache_key(cf)
	return string.format(string.rep('%.1f ', 12), cf:GetComponents())
end

local count = 0
local grace = 0
local tickmark = tick()
_G.build_loop = tickmark
spawn(
	function()
		local queue = _G.build_queue
		while _G.build_loop == tickmark do
			-- Rate limiting.
			if count == FUNCS.BLOCK_CHUNK_SIZE then
				grace = FUNCS.BLOCK_CHUNK_PERIOD
				count = 0
			end
			if grace > 0 then
				wait(grace)
				grace = 0
			end

			if #queue > 0 then
				local queue_args = table.remove(queue)
				local cf = queue_args[1]
				_G.build_cache[cf] = true
				count = count + 1
				spawn(
					function()
						local o = FUNCS.ADD_BLOCK(unpack(queue_args))
						_G.build_cache[cf] = nil
						if o then
							if not FUNCS.WAIT_FOR_BLOCK then
								local k = cache_key(cf)
								_G.build_store[k] = o
							end
						end
						evt:Fire(cf, o)
					end)
			else
				wait()
			end
		end
	end)

if FUNCS.WAIT_FOR_BLOCK then
	spawn(
		function()
			while _G.build_loop == tickmark do
				local obj_cf, obj = FUNCS.WAIT_FOR_BLOCK()
				local near, near_cf

				for cf in next, _G.build_cache do
					local d = obj_cf * cf:inverse()
					local v = d.Position.Magnitude + select(2, d:ToEulerAnglesYXZ())
					if not near or v < near then near, near_cf = v, cf end
				end

				_G.build_store[cache_key(near_cf)] = obj
				_G.build_cache[near_cf] = nil
				evt:Fire(near_cf, obj)
			end
		end)
end

local function make(cfs, ...)
	if not _G.build_last_cleared then return false end
	local last = _G.build_last_cleared
	local c = #cfs
	local a = {...}
	local b = true
	local cf_list = {}

	local store = _G.build_store
	local queue = _G.build_queue

	-- The delay is to give time for the event connection to be made.
	delay(
		1 / 8, function()
			-- Shifts later elements up the queue.
			for i = #queue, 1, -1 do queue[i + #cfs] = queue[i] end

			-- Adds new CFrames to the queue.
			for i, cf in next, cfs do
				cf_list[i] = cf
				local s = cache_key(cf)
				if store[s] == nil then
					store[s] = false
					queue[i] = {cf, unpack(a)}
				end
			end
		end)

	local con = evt.Event:Connect(
		function(cf, obj)
			local i = table.find(cf_list, cf)
			if not i then return end
			table.remove(cf_list, i)
			if not obj then b = false end
			if _G.build_last_cleared ~= last then
				c = 0
				return
			end
			c = c - 1
		end)

	while c > 0 do wait() end
	con:Disconnect()
	return b
end

local function void(cfs)
	for _, cf in next, cfs do
		local s = cache_key(cf)
		if _G.build_store[s] == nil then _G.build_store[s] = false end
	end
end

local function delete(cfs)
	local b = false
	for _, cf in next, cfs do
		local s = cache_key(cf)
		local o = _G.build_store[s]
		if o and o.Parent then b = b or FUNCS.REMOVE_BLOCK(o) end
		_G.build_store[s] = nil
	end
	return b
end

local function reset()
	local b = true
	if FUNCS.CLEAR_BLOCKS then
		FUNCS.CLEAR_BLOCKS()
		for s, o in next, _G.build_store do
			if FUNCS.BLOCK_EXISTS(o) then
				b = false
			else
				_G.build_store[s] = nil
			end
		end
	else
		for s, o in next, _G.build_store do
			if o and o.Parent and not FUNCS.REMOVE_BLOCK(o) then
				b = false
			else
				_G.build_store[s] = nil
			end
		end
	end

	-- Sets clear state and resets the slate.
	if b then
		table.clear(_G.build_queue)
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

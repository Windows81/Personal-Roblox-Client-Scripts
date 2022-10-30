--[==[HELP]==
Loads the following functions into the current execution environment vía genrenv:
{
	make,
	void,
	delete,
	reset,
	box3,   -- Geneator that returns a box of CFrames of a 2D or 3D box.
	sngl,   -- Generator that returns a single CFrame.
	frme,   -- Geneator that returns CFrames arranged in a hollow 2D or 3D box.
	invf,   -- Geneator that returns a box of CFrames of a 2D or 3D box minus the outer layer.
	iter,   -- Generator that offsets an arbitrary parameter.
	join,   -- Join of two or more generators.
}

[1] - function
	Corresponds to the internal ADD_BLOCK function.

[2] - function
	Corresponds to the internal BLOCK_EXISTS function.

[3] - function | nil
	Corresponds to the internal CLEAR_BLOCKS function.

[4] - function | nil
	Corresponds to the internal WAIT_FOR_BLOCK function.

[5] - function | nil
	Corresponds to the internal REMOVE_BLOCK function.

[6] - number | nil
	Corresponds to the internal BLOCK_CHUNK_SIZE parameter.
	If less than 0 or not passed in, insert all blocks at once.

[7] - number | nil
	Grace period between timed chunks in the same insertion action; defaults to 0.
]==] --
--
local raw_args = _E.ARGS
local env = getrenv()

local ARGS = {}
local function arg_load(i, s, d)
	local _, v = next{raw_args[s], env[s], raw_args[i], d}
	ARGS[s] = v
end
arg_load(1, 'ADD_BLOCK')
arg_load(2, 'BLOCK_EXISTS')
arg_load(3, 'CLEAR_BLOCKS')
arg_load(4, 'WAIT_FOR_BLOCK')
arg_load(5, 'REMOVE_BLOCK')
arg_load(6, 'BLOCK_CHUNK_SIZE', -1)
arg_load(7, 'BLOCK_CHUNK_PERIOD', 0)

_G.build_last_cleared = _G.build_last_cleared or tick()
_G.build_evt = _G.build_evt or Instance.new'BindableEvent'
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
task.spawn(
	function()
		local queue = _G.build_queue
		while _G.build_loop == tickmark do
			-- Rate limiting.
			if count == ARGS.BLOCK_CHUNK_SIZE then
				grace = ARGS.BLOCK_CHUNK_PERIOD
				count = 0
			end
			if grace > 0 then
				task.wait(grace)
				grace = 0
			end

			if #queue > 0 then
				local queue_args = queue[#queue]
				local cf = queue_args[1]
				_G.build_cache[cf] = true
				queue[#queue] = nil
				count = count + 1
				task.spawn(
					function()
						local s, o = pcall(ARGS.ADD_BLOCK, unpack(queue_args))
						if not s then o = nil end
						_G.build_cache[cf] = nil
						if o then
							if not ARGS.WAIT_FOR_BLOCK then
								local k = cache_key(cf)
								_G.build_store[k] = o
							end
						end
						_G.build_evt:Fire(cf, o)
					end)
			else
				task.wait()
			end
		end
	end)

if ARGS.WAIT_FOR_BLOCK then
	task.spawn(
		function()
			while _G.build_loop == tickmark do
				local obj_cf, obj = ARGS.WAIT_FOR_BLOCK()
				local near, near_cf

				for cf in next, _G.build_cache do
					local d = obj_cf * cf:inverse()
					local v = d.Position.Magnitude + select(2, d:ToEulerAnglesYXZ())
					if not near or v < near then near, near_cf = v, cf end
				end

				_G.build_store[cache_key(near_cf)] = obj
				_G.build_cache[near_cf] = nil
				_G.build_evt:Fire(near_cf, obj)
			end
		end)
end

local function make(cfs, ...)
	if not _G.build_last_cleared then return false end
	local last = _G.build_last_cleared
	local clear_i = #cfs
	local a = {...}
	local b = true
	local cf_list = {}

	local store = _G.build_store
	local queue = _G.build_queue

	-- The delay is to give time for the event connection to be made.
	task.delay(
		1 / 8, function()
			-- Shifts later elements up the queue.
			for i = #queue, 1, -1 do queue[i + #cfs] = queue[i] end

			-- Adds new CFrames to the queue.
			local queue_i = 1
			for i = #cfs, 1, -1 do
				local cf = cfs[i]
				cf_list[i] = cf
				local s = cache_key(cf)
				if store[s] == nil then
					queue[queue_i] = {cf, unpack(a)}
					queue_i = queue_i + 1
					store[s] = false
				end
			end
		end)

	local con = _G.build_evt.Event:Connect(
		function(cf, obj)
			local i = table.find(cf_list, cf)
			if not i then return end
			table.remove(cf_list, i)
			if not obj then b = false end
			if _G.build_last_cleared ~= last then
				clear_i = 0
				return
			end
			clear_i = clear_i - 1
		end)

	while clear_i > 0 do task.wait() end
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
		if o and o.Parent then b = b or ARGS.REMOVE_BLOCK(o) end
		_G.build_store[s] = nil
	end
	return b
end

local function reset()
	local b = true
	table.clear(_G.build_queue)
	while next(_G.build_cache) do _G.build_evt.Event:Wait() end
	table.clear(_G.build_queue)
	if ARGS.CLEAR_BLOCKS then
		ARGS.CLEAR_BLOCKS()
		for s, o in next, _G.build_store do
			if ARGS.BLOCK_EXISTS(o) then
				b = false
			else
				_G.build_store[s] = nil
			end
		end
	else
		for s, o in next, _G.build_store do
			if o and o.Parent and not ARGS.REMOVE_BLOCK(o) then
				b = false
			else
				_G.build_store[s] = nil
			end
		end
	end

	-- Toggles clear state and resets the slate.
	if b then
		_G.build_last_cleared = nil
		task.wait(1)
		_G.build_last_cleared = tick()
	end
	return b
end

-- Geneator that returns a box of CFrames of a 2D or 3D box.
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

-- Geneator that returns a box of CFrames of a 2D or 3D box minus the outer layer.
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

--[==[HELP]==
Loads the following functions into the current execution environment vía genrenv:
{
	make,
	void,   -- Prevents CFrames used in later calls to 'make' from being filled in.
	delete,
	clear,

	box3,   -- Geneator that returns a box of CFrames of a 2D or 3D box.
	sngl,   -- Generator that returns a single CFrame.
	frme,   -- Geneator that returns CFrames arranged in a hollow 2D or 3D box.
	invf,   -- Geneator that returns a box of CFrames of a 2D or 3D box minus the outer layer.
	join,   -- Join of two or more generators.
}

[1] - {[string]:any}
	Optional table which is used to supply all internal functions.

	ADD_BLOCK - (CFrame, *any)->()

	BLOCK_EXISTS - (Instance)->bool

	CLEAR_BLOCKS - (bool)->(bool) | nil

	BLOCK_EVENT - Signal | nil

	CHECK_BLOCK - (Instance)->(CFrame) | nil

	REMOVE_BLOCK - (Instance)->(bool) | nil

	BLOCK_CHUNK_SIZE - number | nil
		If less than 0 or not passed in, insert all blocks at once.

	BLOCK_CHUNK_PERIOD - number | nil
		Grace period between timed chunks in the same insertion action; defaults to 0.

	WAIT_RANGE - number | nil
		Corresponds to the internal  parameter.
		Maximum distance from CFrame returned from BLOCK_EVENT to register as having been passed in from 'make'.
]==] --
--
local raw_args = _E and _E.ARGS or {}
local fenv = getfenv()
local renv = getrenv()

local ARGS = {}
local function arg_load(s, d)
	local _, v = next{raw_args[s], fenv[s], d}
	ARGS[s] = v
end
arg_load('ADD_BLOCK')
arg_load('BLOCK_EXISTS')
arg_load('CLEAR_BLOCKS')
arg_load('BLOCK_EVENT')
arg_load('CHECK_BLOCK')
arg_load('REMOVE_BLOCK')
arg_load('REMOVE_BLOCKS')
arg_load('BLOCK_CHUNK_SIZE', -1)
arg_load('BLOCK_CHUNK_PERIOD', 0)
arg_load('WAIT_RANGE', 1e-5)

_G.build_last_cleared = _G.build_last_cleared or tick()
_G.build_evt = _G.build_evt or Instance.new'BindableEvent'
_G.build_store = _G.build_store or {}
_G.build_cache = _G.build_cache or {}
_G.build_queue = _G.build_queue or {}

local function cache_key(cf)
	return string.format(string.rep('%.1f ', 12), cf:GetComponents())
end

local function expand_in(cfs)
	if type(cfs) ~= 'table' then cfs = {cfs} end
	local r = {}
	for _, v in next, cfs do
		local typ = typeof(v)
		if typ == 'Vector3' then
			v = CFrame.new(v)
		elseif typ == 'table' then
			local tab = expand_in(v)
			table.move(tab, 1, #tab, #r + 1, r)
			v = nil
		end

		if v then table.insert(r, v) end
	end
	return r
end

local function hash_insert(cfs, h, trans)
	for _, cf in next, cfs do
		local v = cf * trans
		h[cache_key(v)] = v
	end
end

local function expand_out(h)
	local r = {}
	for _, cf in h do table.insert(r, cf) end
	return r
end

local count = 0
local grace = 0
local tickmark = tick()
_G.build_loop = tickmark
task.spawn(
	function()
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

			local queue = _G.build_queue
			if #queue > 0 then
				local queue_args = queue[#queue]
				local cf = queue_args[1]
				_G.build_cache[cf] = true
				queue[#queue] = nil
				count = count + 1
				task.spawn(
					function()
						local call_s, run_s, obj = pcall(ARGS.ADD_BLOCK, unpack(queue_args))
						local success = call_s and run_s
						if not success then
							_G.build_cache[cf] = nil
							_G.build_evt:Fire(cf, nil)
							return
						end

						-- If BLOCK_EVENT doesn't exists, assume the object is the second return of ADD_BLOCK.
						if ARGS.BLOCK_EVENT or ARGS.CHECK_BLOCK then return end
						if not obj then
							_G.build_cache[cf] = nil
							_G.build_evt:Fire(cf, nil)
							return
						end
						_G.build_store[cache_key(cf)] = obj
						_G.build_cache[cf] = nil
						_G.build_evt:Fire(cf, obj)
					end)
			else
				task.wait()
			end
		end
	end)

if ARGS.BLOCK_EVENT then
	local con
	con = ARGS.BLOCK_EVENT:Connect(
		function(obj)
			local check_cf = ARGS.CHECK_BLOCK(obj)
			-- print('CFrame', check_cf)
			if _G.build_loop ~= tickmark then
				con:Disconnect()
				return
			end

			if check_cf then
				local near, near_cf
				for cf in next, _G.build_cache do
					-- print('CFrame compare', check_cf)
					local d = check_cf.Position - cf.Position
					local v = d.Magnitude
					if not near or near > v then near, near_cf = v, cf end
				end

				-- print('CFrame delta', near)
				if near_cf and (ARGS.WAIT_RANGE < 0 or near <= ARGS.WAIT_RANGE) then
					_G.build_store[cache_key(near_cf)] = obj
					_G.build_cache[near_cf] = nil
					_G.build_evt:Fire(near_cf, obj)
				end
			end
		end)
end

local function make(cfs, ...)
	if not _G.build_last_cleared then return false end
	local last = _G.build_last_cleared
	local cfs = expand_in(cfs)
	local queue_i = 0
	local clear_i = 0
	local a = {...}
	local cf_list = {}
	local b = false

	local store = _G.build_store
	local queue = _G.build_queue

	local con = _G.build_evt.Event:Connect(
		function(cf, obj)
			local i = table.find(cf_list, cf)
			if not i then return end
			table.remove(cf_list, i)
			if obj then b = true end
			if _G.build_last_cleared ~= last then
				clear_i = queue_i
				return
			end
			clear_i = clear_i + 1
			print(queue_i, clear_i)
		end)

	-- Adds new CFrames to the queue.
	local queue_seg = {}
	for i = #cfs, 1, -1 do
		local cf = cfs[i]
		cf_list[i] = cf
		local k = cache_key(cf)
		if store[k] == nil then
			table.insert(queue_seg, {cf, unpack(a)})
			queue_i = queue_i + 1
			store[k] = false
		end
	end

	-- Shifts later elements up the queue.
	table.move(queue_seg, 1, queue_i, #queue + 1, queue)

	while clear_i ~= queue_i do task.wait() end
	con:Disconnect()
	return b
end

local function void(cfs)
	local cfs = expand_in(cfs)
	for _, cf in next, cfs do
		local s = cache_key(cf)
		if _G.build_store[s] == nil then _G.build_store[s] = false end
	end
end

local function delete(cfs)
	local cfs = expand_in(cfs)
	local function delete_many()
		local b = false
		local blocks = {}
		for _, cf in next, cfs do
			local s = cache_key(cf)
			local o = _G.build_store[s]
			if o and o.Parent then
				table.insert(blocks, o)
				b = true
			end
			_G.build_store[s] = nil
		end
		return b and ARGS.REMOVE_BLOCKS(blocks)
	end

	local function delete_each()
		local b = false
		for _, cf in next, cfs do
			local s = cache_key(cf)
			local o = _G.build_store[s]
			if o and o.Parent then b = b or ARGS.REMOVE_BLOCK(o) end
			_G.build_store[s] = nil
		end
		return b
	end

	if ARGS.REMOVE_BLOCKS then
		return delete_many()
	else
		return delete_each()
	end
end

local function clear(force)
	local function check(o) return o and o.Parent end
	if ARGS.BLOCK_EXISTS then
		check = function(o)
			if not o then return false end
			return ARGS.BLOCK_EXISTS(o)
		end
	end

	while next(_G.build_cache) do _G.build_evt.Event:Wait() end
	table.clear(_G.build_queue)

	local function clear_global()
		local b = true
		ARGS.CLEAR_BLOCKS()
		for s, o in next, _G.build_store do
			if check(o) then
				b = false
			else
				_G.build_store[s] = nil
			end
		end
		return b
	end

	local function clear_many()
		local blocks = {}
		for _, o in next, _G.build_store do table.insert(blocks, o) end
		if not ARGS.REMOVE_BLOCKS(blocks) then return false end

		local b = true
		for s, o in next, _G.build_store do
			if check(o) then
				b = false
			else
				_G.build_store[s] = nil
			end
		end
		return b
	end

	local function clear_each()
		local b = true
		for s, o in next, _G.build_store do
			if o and o.Parent then
				if not ARGS.REMOVE_BLOCK(o) then b = false end
			else
				_G.build_store[s] = nil
			end
		end
		return b
	end

	local b
	if ARGS.CLEAR_BLOCKS then
		b = clear_global()
	elseif ARGS.REMOVE_BLOCKS then
		b = clear_many()
	else
		b = clear_each()
	end

	-- Toggles clear state and resets the slate.
	if b or force then
		_G.build_last_cleared = nil
		task.wait(1)
		_G.build_last_cleared = tick()
	end
	return b
end

-- Generator that returns a single CFrame.
local function sngl(cf) return {cf} end

-- Geneator that returns a box of CFrames of a 2D or 3D box.
local function box3(cfs, d, x, y, z)
	local cfs = expand_in(cfs)
	local h = {}
	for X = 0, x, x > 0 and 1 or -1 do
		for Y = 0, y, y > 0 and 1 or -1 do
			for Z = 0, z, z > 0 and 1 or -1 do
				local trans = CFrame.new(d * X, d * Y, d * Z)
				hash_insert(cfs, h, trans)
			end
		end
	end
	return expand_out(h)
end

-- Geneator that returns CFrames arranged in a hollow 2D or 3D box.
local function frme(cfs, d, x, y, z)
	local cfs = expand_in(cfs)
	local h = {}
	for X = 0, x, x > 0 and 1 or -1 do
		for Y = 0, y, y > 0 and 1 or -1 do
			for Z = 0, z, z > 0 and 1 or -1 do
				local cX = (X == 0) ~= (x == X)
				local cY = (Y == 0) ~= (y == Y)
				local cZ = (Z == 0) ~= (z == Z)
				if cX or cY or cZ then
					local trans = CFrame.new(d * X, d * Y, d * Z)
					hash_insert(cfs, h, trans)
				end
			end
		end
	end
	return expand_out(h)
end

-- Geneator that returns a box of CFrames of a 2D or 3D box minus the outer layer.
local function invf(cfs, d, x, y, z)
	local cfs = expand_in(cfs)
	local h = {}
	for X = 0, x, x > 0 and 1 or -1 do
		for Y = 0, y, y > 0 and 1 or -1 do
			for Z = 0, z, z > 0 and 1 or -1 do
				local cX = (X == 0) == (x == X)
				local cY = (Y == 0) == (y == Y)
				local cZ = (Z == 0) == (z == Z)
				if cX and cY and cZ then
					local trans = CFrame.new(d * X, d * Y, d * Z)
					hash_insert(cfs, h, trans)
				end
			end
		end
	end
	return expand_out(h)
end

-- Join of two or more generators.
local function join(...)
	local h = {}
	for _, cfs in next, {...} do
		for _, cf in next, expand_in(cfs) do --
			h[cache_key(cf)] = cf
		end
	end
	return expand_out(h)
end

local function shft(cfs, trans)
	local r = {}
	for _, cf in next, expand_in(cfs) do table.insert(r, cf * trans) end
	return r
end

renv.make = make
renv.void = void
renv.delete = delete
renv.clear = clear

renv.box3 = box3
renv.sngl = sngl
renv.frme = frme
renv.invf = invf
renv.join = join
renv.shft = shft

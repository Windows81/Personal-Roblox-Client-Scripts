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

	BLOCK_TIMEOUT - number | nil
		Maximum time to expect blocks to be built using 'make'.
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
arg_load('WAIT_RANGE', 1e-3)
arg_load('BLOCK_TIMEOUT', 5e-1)

_G.build_last_cleared = _G.build_last_cleared or tick()
_G.build_evt = _G.build_evt or Instance.new'BindableEvent'
_G.build_store = _G.build_store or {}
_G.build_cache = _G.build_cache or {}
_G.build_queue = _G.build_queue or {}

local function is_halt(flag) return flag == 'HALT' end
_G.build_evt:Fire('HALT')

local function cache_key(cf)
	local t = {}
	for i, c in next, {cf:GetComponents()} do
		t[i] = tostring(math.round(c * 16) / 16)
	end
	return table.concat(t, ' ')
end

local function expand_in(cfs)
	if type(cfs) ~= 'table' then cfs = {cfs} end
	local r = {}
	for i, v in next, cfs do
		if typeof(i) == 'table' then
			r[i] = expand_in(v)
		else
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

local function proc_queue(cf, ...)
	_G.build_cache[cf] = true
	-- print('CFrame added', cf)
	local call_s, run_s, obj = pcall(ARGS.ADD_BLOCK, cf, ...)
	local success = call_s and run_s
	if not success then return true, nil end

	-- If BLOCK_EVENT doesn't exist, assume the object is the second return of ADD_BLOCK.
	if ARGS.BLOCK_EVENT then return false end

	if not obj then return true, nil end
	return true, obj
end

local function fire_queue(cf, obj)
	_G.build_cache[cf] = nil
	_G.build_store[cache_key(cf)] = obj
	_G.build_evt:Fire(cf, obj)
end

local function do_race(race)
	local con
	con = _G.build_evt.Event:Connect(
		function(cf) --
			if is_halt(cf) then
				con:Disconnect()
				return
			end
			race[cache_key(cf)] = nil
		end)

	for _, queue_args in next, race do
		spawn(
			function()
				local cf = queue_args[1]
				local suc, obj = proc_queue(cf, unpack(queue_args, 2))
				if suc then fire_queue(cf, obj) end
				print('Suc', cf, suc)
			end)
	end

	while next(race) do
		print('CFrame race 1', next(race))
		local cf = _G.build_evt.Event:Wait()
		print('CFrame race 2', cf)
		if is_halt(cf) then
			con:Disconnect()
			return
		end
		race[cache_key(cf)] = nil
	end

	con:Disconnect()
	if ARGS.BLOCK_CHUNK_PERIOD > 0 then --
		task.wait(ARGS.BLOCK_CHUNK_PERIOD)
	end
end

function iter_queue()
	-- Connection which terminates the queue loop when the halt flag is passed through 'build_evt'.
	local flag_con
	flag_con = _G.build_evt.Event:Connect(
		function(flag)
			if is_halt(flag) then --
				flag_con:Disconnect()
			end
		end)

	local mod = 0
	local race = {}
	while flag_con.Connected do
		local queue = _G.build_queue
		local queue_l = #queue
		if queue_l > 0 then
			mod = (mod + 1) % ARGS.BLOCK_CHUNK_SIZE
			local queue_args = queue[queue_l]
			local cf = queue_args[1]
			race[cache_key(cf)] = queue_args
			queue[queue_l] = nil

			if ARGS.BLOCK_CHUNK_SIZE > 0 and mod == 0 or queue_l == 1 then --
				do_race(race)
				print('Race done')
			end
		else
			task.wait()
		end
	end
end
task.spawn(iter_queue)

if ARGS.BLOCK_EVENT then
	-- Connection which terminates BLOCK_EVENT when the halt flag is passed through 'build_evt'.
	local flag_con
	local blk_con
	flag_con = _G.build_evt.Event:Connect(
		function(flag)
			if is_halt(flag) then
				blk_con:Disconnect()
				flag_con:Disconnect()
			end
		end)

	blk_con = ARGS.BLOCK_EVENT:Connect(
		function(obj)
			local check_cf = ARGS.CHECK_BLOCK(obj)
			print('CFrame check', check_cf)

			if check_cf then
				local near, near_cf
				for cf in next, _G.build_cache do
					print('CFrame compare', check_cf)
					local d = check_cf.Position - cf.Position
					local v = d.Magnitude
					if not near or near > v then near, near_cf = v, cf end
				end

				print('CFrame delta', near)
				if near_cf and (ARGS.WAIT_RANGE < 0 or near <= ARGS.WAIT_RANGE) then
					fire_queue(near_cf, obj)
				end
			end
		end)
end

local function make(cfs, ...)
	if not _G.build_last_cleared then return false end
	local last = _G.build_last_cleared
	local cfs = expand_in(cfs)
	local clear_i = 0
	local len = 0

	local cf_list = {}
	local b = false

	-- Adds new CFrames to the queue.
	local queue_seg = {}
	local function add_to_queue(cf, ...)
		local k = cache_key(cf)
		if _G.build_store[k] == nil then
			table.insert(queue_seg, {cf, ...})
			table.insert(cf_list, cf)
			_G.build_store[k] = false
			len = len + 1
		end
	end

	for i = #cfs, 1, -1 do
		add_to_queue(cfs[i], ...) --
	end

	for i, cf_t in next, cfs do
		if typeof(i) == 'table' then
			for _, cf in next, cf_t do
				add_to_queue(cf, unpack(i)) --
			end
		end
	end

	-- Returns success if there are no CFrames to act on.
	print('Len', len)
	if len == 0 then return true end

	local con
	local done = false
	local function mark_done()
		con:Disconnect()
		done = true
	end

	con = _G.build_evt.Event:Connect(
		function(cf, obj)
			if is_halt(cf) then
				mark_done()
				return
			end

			local i = table.find(cf_list, cf)
			if not i then return end
			table.remove(cf_list, i)

			if obj then b = true end
			if _G.build_last_cleared ~= last then
				mark_done()
				return
			end
			clear_i = clear_i + 1
			if clear_i == len then
				mark_done()
				return
			end
			-- print(queue_i, clear_i)
		end)

	-- Shifts later elements up the queue.
	table.move(queue_seg, 1, len, #_G.build_queue + 1, _G.build_queue)

	-- Hold until the list is complete or timeout 'dur' is passed, whichever happens first.
	local max_ts = tick() + len * ARGS.BLOCK_TIMEOUT + 2
	while not done and tick() < max_ts do task.wait() end

	for _, cf in next, cf_list do _G.build_cache[cf] = nil end
	-- print('Done')
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

local function check(o) return o and (typeof(o) ~= 'Instance' or o.Parent) end
if ARGS.BLOCK_EXISTS then
	check = function(o)
		if not o then return false end
		return ARGS.BLOCK_EXISTS(o)
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
			if check(o) then
				table.insert(blocks, o)
				b = true
			end
			_G.build_store[s] = nil
		end
		return b and ARGS.REMOVE_BLOCKS(blocks)
	end

	local function delete_each()
		local b = true
		for _, cf in next, cfs do
			local s = cache_key(cf)
			local o = _G.build_store[s]
			if check(o) then if not ARGS.REMOVE_BLOCK(o) then b = false end end
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
	while next(_G.build_cache) do _G.build_evt.Event:Wait() end
	table.clear(_G.build_queue)

	local function clear_global()
		local b = true
		ARGS.CLEAR_BLOCKS()
		for s, o in next, _G.build_store do
			if check(o) then b = false end
			_G.build_store[s] = nil
		end
		return b
	end

	local function clear_many()
		local blocks = {}
		for _, o in next, _G.build_store do table.insert(blocks, o) end
		if not ARGS.REMOVE_BLOCKS(blocks) then return false end

		local b = true
		for s, o in next, _G.build_store do
			if check(o) then b = false end
			_G.build_store[s] = nil
		end
		return b
	end

	local function clear_each()
		local b = true
		for s, o in next, _G.build_store do
			if check(o) and not ARGS.REMOVE_BLOCK(o) then b = false end
			_G.build_store[s] = nil
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

local function shft(cfs, trans, copy)
	local r = copy and expand_in(cfs) or {}
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

--[==[HELP]==
To be used with "Blocks!" by Darin's Games.
]==] --
--
-- #region Game-specific functions.
local network = game.ReplicatedStorage.shared.network['network_contents']
function ADD_BLOCK(cf, s)
	local r = cf - cf.Position
	network['place_build']:FireServer(s, cf.X, cf.Y, cf.Z, r, 1, 1)
	return true
end

function BLOCK_EXISTS(o) return o and o.Parent end

function CLEAR_BLOCKS() return false end

BLOCK_EVENT = game.Workspace['created_blocks'].ChildAdded
function CHECK_BLOCK(o) return o:WaitForChild 'Part'.CFrame end

function REMOVE_BLOCK(o)
	network['remove_build']:FireServer(o.Name)
	return true
end
-- #endregion

-- #region Build functions.
_G.build_cache = _G.build_cache or {}
function cache_key(cf) return string.format('%.1f %.1f %.1f', cf.x, cf.y, cf.z) end
function make(cfs, ...)
	if not _G.build_last_cleared then return false end
	local args = {...}
	local b = false
	local r = {}
	local c = 0
	local n = 0
	for i, cf in next, cfs do
		local s = cache_key(cf)
		if _G.build_cache[s] == nil then
			_G.build_cache[s] = false
			delay(i / 32 + 3 / 16, function() ADD_BLOCK(cf, unpack(args)) end)
			c = c + 1
		end
	end
	if c == 0 then return false end

	local cfh = {}
	for _, cf in next, cfs do cfh[cf] = true end

	local last = _G.build_last_cleared
	while true do
		b = true
		n = n + 1
		local ocf, o = task.BLOCK_EVENT()
		local min, mcf
		for cf in next, cfh do
			local d = ocf * cf:inverse()
			local v = d.Position.Magnitude + select(2, d:ToEulerAnglesYXZ())
			if not min or v < min then min, mcf = v, cf end
		end

		if _G.build_last_cleared ~= last then return false end
		_G.build_cache[cache_key(mcf)] = o
		cfh[mcf] = nil
		r[#r + 1] = o
		print(n, c, mcf)
		if n == c then return b, r end
	end
end

function void(cfs)
	for _, cf in next, cfs do
		local s = cache_key(cf)
		if _G.build_cache[s] == nil then _G.build_cache[s] = false end
	end
end

function delete(cfs)
	local b = false
	for _, cf in next, cfs do
		local s = cache_key(cf)
		local o = _G.build_cache[s]
		if o and o.Parent then b = b or REMOVE_BLOCK(o) end
		_G.build_cache[s] = nil
	end
	return b
end

function reset()
	local b = true
	CLEAR_BLOCKS()
	for s, o in next, _G.build_cache do
		if BLOCK_EXISTS(o) then
			b = false
		else
			_G.build_cache[s] = nil
		end
	end
	if b then
		_G.build_last_cleared = nil
		task.wait(1)
		_G.build_last_cleared = tick()
	end
	return b
end

-- Geneator that returns o box of CFrames of a 2D or 3D box.
function box3(cf, x, y, z, d)
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
function sngl(cf) return {cf} end

-- Geneator that returns CFrames arranged in a hollow 2D or 3D box.
function frme(cf, x, y, z, d)
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
function invf(cf, x, y, z, d)
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
function iter(f, num_calls, arg_num, arg_inc, ...)
	local r = {}
	local args = {...}
	local iscf = typeof(arg_inc) == 'CFrame'
	for _ = 1, num_calls do
		for _, cf in next, f(unpack(args)) do r[#r + 1] = cf end
		if iscf then
			args[arg_num] = arg_inc * args[arg_num]
		else
			args[arg_num] = arg_inc + args[arg_num]
		end
	end
	return r
end

-- Join of two or more generators.
function join(args)
	local r = {}
	for _, t in next, args do for _, cf in next, t do r[#r + 1] = cf end end
	return r
end

-- #endregion

local BASE = CFrame.new(-8, -1, -386)
local FLOORS = 7
local SIZE = 7
local OFFSET = 3

reset()
local t = {}
for i = 1, 7 do
	local w = 13 - 2 * i
	t[i] = frme(
		BASE * CFrame.new(-w * OFFSET / 2, i * OFFSET / 2, -w * OFFSET / 2), w, 1, w,
			OFFSET)
end
make(join(t), 'Dark Red')

--[[
function tower(MAT1, MAT2, BASE, FLOORS, SIZE)
	BASE = BASE * CFrame.new(3 * SIZE / 2, 0, -3 * SIZE / 2)
	make(
		'Colors', 'White', join{
			--
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-3, 3, 3 * SIZE - 3)),
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-12, 9, 3 * SIZE - 3)),
		})

	local stair_off = CFrame.new(.25, 0, .04)
	make(
		'Furniture', 'Stair', join{
			--
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-3, 3, 3 * SIZE - 6) * CFrame.Angles(0, 0, 0) * stair_off),
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-3, 0, 3 * SIZE - 6) * CFrame.Angles(math.pi, 0, 0) *
						stair_off),
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-6, 6, 3 * SIZE - 3) * CFrame.Angles(0, -math.pi / 2, 0) *
						stair_off),
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-6, 3, 3 * SIZE - 3) *
						CFrame.Angles(math.pi, math.pi / 2, 0) * stair_off),
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-9, 9, 3 * SIZE - 3) * CFrame.Angles(0, -math.pi / 2, 0) *
						stair_off),
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-9, 6, 3 * SIZE - 3) *
						CFrame.Angles(math.pi, math.pi / 2, 0) * stair_off),
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-12, 12, 3 * SIZE - 6) * CFrame.Angles(0, math.pi, 0) *
						stair_off),
			iter(
				sngl, FLOORS - 1, 1, CFrame.new(0, 12, 0),
					BASE * CFrame.new(-12, 9, 3 * SIZE - 6) * CFrame.Angles(0, 0, math.pi) *
						stair_off),
		})

	void(
		join{
			--
			invf(BASE * CFrame.new(0, 0, 6), 0, 3, 2),
			invf(BASE * CFrame.new(0, 0, 3 * SIZE), -5, 4 * FLOORS, -3),
		})
	make(
		MAT1, MAT2, join{
			--
			iter(
				base, FLOORS, 1, CFrame.new(0, 12, 0), BASE * CFrame.new(0, 0, 0), -SIZE, 0,
					SIZE),
			iter(
				frme, FLOORS, 1, CFrame.new(0, 12, 0), BASE * CFrame.new(0, 3, 0), -SIZE, 0,
					SIZE, 6),
			frme(BASE * CFrame.new(0, 0, 6), 0, 3, 2),
		})

	make(
		'Materials', 'Glass', join{
			--
			iter(
				frme, FLOORS, 1, CFrame.new(0, 12, 0), BASE * CFrame.new(0, 6, 0), -SIZE, 0,
					SIZE),
			iter(
				frme, FLOORS, 1, CFrame.new(0, 12, 0), BASE * CFrame.new(0, 9, 0), -SIZE, 0,
					SIZE),
			base(BASE * CFrame.new(0, FLOORS * 12, 0), -SIZE, 0, SIZE),
		})
end

clear()
task.wait(2)

for a = 0, math.pi * 2 - 1e-2, 2 * math.pi / 7 do
	tower(
		'Colors', 'Red', BASE * CFrame.Angles(0, a + (math.random() - .5) / 5, 0) *
			CFrame.new(-40, 0, 0), FLOORS - math.random(0, 3), SIZE)
end
]]

local BASE = CFrame.new(109, 0, 1)
local FLOORS = 7
local SIZE = 7

local COMBOS = {
	{'Colors', 'Purple'},
	{'Colors', 'Red'},
	{'Colors', 'Blue'},
	{'Colors', 'Green'},
	{'Colors', 'Yellow'},
	{'Colors', 'Black'},
	{'Colors', 'White'},
	{'Colors', 'Brown'},
	{'Colors', 'Gray'},
	{'Colors', 'Rainbow'},
	{'Furniture', 'Bed'},
	{'Furniture', 'Chair'},
	{'Furniture', 'Door'},
	{'Furniture', 'Sofa'},
	{'Furniture', 'Stair'},
	{'Furniture', 'Table'},
	{'Furniture', 'TreasureChest'},
	{'Furniture', 'Bookshelf'},
	{'Furniture', 'Dishwasher'},
	{'Materials', 'Glass'},
	{'Materials', 'Marble'},
	{'Materials', 'Grass'},
	{'Materials', 'Brick'},
	{'Materials', 'DiamondPlate'},
	{'Decorations', 'Plant'},
	{'Decorations', 'SmallTree'},
	{'Decorations', 'Mailbox'},
	{'Decorations', 'Flowers'},
	{'Decorations', 'streetLamp'},
	{'Decorations', 'Refrigarator'},
	{'Decorations', 'Toilet'},
	{'Decorations', 'Sink'},
	{'Decorations', 'Fireplace'},
	{'Decorations', 'KREWLogo'},
	{'Decorations', 'DogeBlock'},
	{'FUN', 'Spike_Retracting'},
	{'FUN', 'Spikes_Simple'},
	{'FUN', 'FirePit'},
	{'FUN', 'SmallElevator'},
	{'FUN', 'LargeElevator'},
	{'Rainbow', 'RainbowBed'},
	{'Rainbow', 'RainbowRamp'},
	{'Rainbow', 'RainbowBlock'},
	{'Rainbow', 'RainbowSphere'},
	{'Rainbow', 'RainbowCylinder'},
	{'Rainbow', 'RainbowSculpture'},
	{'Rainbow', 'RainbowDoor'},
	{'Rainbow', 'RainbowMailbox'},
	{'Golden', 'GoldenHammer'},
	{'Golden', 'GoldBed'},
	{'Golden', 'GoldSphere'},
	{'Golden', 'GoldBlock'},
	{'Golden', 'Gold Door'},
	{'Golden', 'GoldChest'},
	{'4thJuly', 'American Cube'},
	{'4thJuly', 'Eagle Statue'},
	{'4thJuly', 'Statue Of Liberty Statue'},
	{'4thJuly', 'American Bed'},
	{'Beach', 'Sand_Stairs'},
	{'Beach', 'SandCastle'},
	{'Beach', 'SandMailbox'},
	{'Beach', 'BeachUmbrella'},
	{'Beach', 'Sand Block'},
	{'Disco', 'Dj_Table'},
	{'Disco', 'Disco_Floor'},
	{'Disco', 'Disco_Cube'},
	{'Disco', 'Disco_Ball'},
	{'Pirate', 'Pirate-Flag'},
	{'Pirate', 'Pirate_Block'},
	{'Pirate', 'Pirate_Cannon'},
	{'Pirate', 'Pirate_chest'},
	{'Pirate', 'PirateWheel'},
	{'Pirate', 'PirateBarrel'},
	{'SquidPack', 'Pink Block'},
	{'SquidPack', 'Green Block'},
	{'SquidPack', 'Door'},
	{'SquidPack', 'Screen'},
	{'SquidPack', 'Piggy'},
	{'SquidPack', 'Bed'},
	{'SquidPack', 'Blue Ramp'},
	{'SquidPack', 'Ramp'},
	{'Meme', 'Block1'},
	{'Meme', 'Block2'},
	{'Meme', 'Block3'},
	{'Meme', 'Block4'},
	{'Meme', 'Block5'},
	{'Meme', 'Door'},
	{'Meme', 'OpenDoor'},
	{'Meme', 'Ramp'},
	{'Snow', 'FirePlace'},
	{'Snow', 'IceCube'},
	{'Snow', 'SnowBench'},
	{'Snow', 'Roof'},
	{'Snow', 'WoodenBench'},
	{'Snow', 'SnowMan'},
	{'Snow', 'PineTree'},
	{'Snow', 'DoorPart'},
	{'Christmas', 'Santa'},
	{'Christmas', 'Snowman'},
	{'Christmas', 'Candles'},
	{'Christmas', 'Candy'},
	{'Christmas', 'PresentBox'},
	{'Christmas', 'Mug'},
	{'Christmas', 'Tree'},
	{'Blocky', 'Book'},
	{'Blocky', 'Chest'},
	{'Blocky', 'Diamond'},
	{'Blocky', 'Table'},
	{'Blocky', 'TNT'},
	{'Blocky', 'Gravel'},
	{'Blocky', 'Grass'},
	{'Blocky', 'Fire'},
}

function cache_key(cf) return string.format('%.1f %.1f %.1f', cf.x, cf.y, cf.z) end

local pl = game.Players.LocalPlayer
_G.build_cache = _G.build_cache or {}

function make(cat, itm, cfs)
	if _G.build_cleared then return false end
	local b = false
	local r = {}
	local c = 0
	local i = 0
	for _, cf in next, cfs do
		local s = cache_key(cf)
		if _G.build_cache[s] == nil then
			_G.build_cache[s] = false
			c = c + 1
			task.delay(
				.2, function()
					game.ReplicatedStorage.BuildingSystemModel.Remotes.Place:InvokeServer(
						itm, CFrame.new(cf.Position), cf.Rotation, cat)
				end)
		end
	end
	if c == 0 then return false end
	while true do
		i = i + 1
		b = true
		local o = game.Workspace.Bases[pl.Name].Items.ChildAdded:Wait()
		if _G.build_cleared then return false end
		_G.build_cache[cache_key(cfs[i])] = o
		r[#r + 1] = o
		print(i, c)
		if i == c then return b, r end
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
		if o and o.Parent then
			b = true
			game.ReplicatedStorage.BuildingSystemModel.Remotes.Delete:FireServer(o)
		end
		_G.build_cache[s] = nil
	end
	return b
end

function clear()
	local b = false
	for s, o in next, _G.build_cache do
		if o and o.Parent then b = true end
		_G.build_cache[s] = nil
	end
	game.ReplicatedStorage.Events.ResetBase:FireServer()
	_G.build_cleared = true
	for _ = 1, 10 do
		local t = Instance.new('Folder', game.Workspace.Bases[pl.Name].Items)
		task.wait()
		t:Destroy()
	end
	_G.build_cleared = false
	return b
end

function base(cf, x, y, z)
	local t = {}
	local i = 0
	for X = 0, x, x > 0 and 1 or -1 do
		for Y = 0, y, y > 0 and 1 or -1 do
			for Z = 0, z, z > 0 and 1 or -1 do
				i = i + 1
				t[i] = cf * CFrame.new(3 * X, 3 * Y, 3 * Z)
			end
		end
	end
	return t
end

function sngl(cf) return {cf} end

function frme(cf, x, y, z)
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
					t[i] = cf * CFrame.new(3 * X, 3 * Y, 3 * Z)
				end
			end
		end
	end
	return t
end

function invf(cf, x, y, z)
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
					t[i] = cf * CFrame.new(3 * X, 3 * Y, 3 * Z)
				end
			end
		end
	end
	return t
end

function iter(f, num_calls, arg_num, arg_inc, ...)
	local r = {}
	local args = {...}
	for _ = 1, num_calls do
		for _, cf in next, f(unpack(args)) do r[#r + 1] = cf end
		args[arg_num] = arg_inc * args[arg_num]
	end
	return r
end

function join(args)
	local r = {}
	for _, t in next, args do for _, cf in next, t do r[#r + 1] = cf end end
	return r
end

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

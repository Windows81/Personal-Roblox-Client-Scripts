--[==[HELP]==
To be used with "A Blockate World.".
]==] --
--
---@diagnostic disable: undefined-global
if not _E then error'This routine is designed for Rsexec.' end

-- #region
local MATERIALS = {}
local SHAPES = {}
local SIZES = {
	['Full'] = 1,
	['SlabY'] = 2,
	['SlabX'] = 3,
	['SlabZ'] = 4,
	['Small'] = 5,
	['PillarY'] = 6,
	['PillarX'] = 7,
	['PillarZ'] = 8,
}

local gui = game.Players.LocalPlayer.PlayerGui.MainGUI.ScreenGui
for _, dd in next, gui:GetChildren() do
	local t = {}
	local options = dd:FindFirstChild('Content', true)
	if options then
		local op_i = 1
		for _, op in next, options:GetDescendants() do
			if op.ClassName == 'TextButton' then
				t[op.Text] = op_i
				op_i = op_i + 1
			end
		end
	end
	if t['Plastic'] then
		MATERIALS = t
	elseif t['Block'] then
		SHAPES = t
	end
end

local function axis_string(n)
	local int = math.round(n)
	local m = n % 1
	local sign = ''
	local signed = false
	if m == 0.25 then
		signed = true
		sign = '+'
	elseif m == 0.75 then
		signed = true
		sign = '-'
	elseif m == 0.00 then
	else
		error('Grid coordinate is not valid.')
	end
	return string.format('%d%s', int, sign), signed
end

local function rot_string(cf)
	local d = math.deg(select(2, cf:ToEulerAnglesYXZ()))
	local a = math.round(d) % 360
	if a == 270 then
		return '16'
	elseif a == 180 then
		return '4'
	elseif a == 90 then
		return '20'
	elseif a == 0 then
		return '0'
	else
		error('Grid rotation isn\'t valid.')
	end
end

-- Determines the block size from the mod-1 of each grid coordinate.
local SIZE_MAP = {
	[true] = {
		[true] = { --
			[true] = 'Small',
			[false] = 'PillarZ',
		},
		[false] = { --
			[true] = 'PillarY',
			[false] = 'SlabX',
		},
	},
	[false] = {
		[true] = { --
			[true] = 'PillarX',
			[false] = 'SlabY',
		},
		[false] = { --
			[true] = 'SlabZ',
			[false] = 'Full',
		},
	},
}
local function size_num(sx, sy, sz)
	local m = SIZE_MAP[sx][sy][sz]
	return SIZES[m]
end

function ADD_BLOCK(cf, colour, material, shape)
	-- proj_cf will be used to determine axis mod%1 classes after rotation.
	local proj_cf = cf.Rotation * cf
	local str_x, sign_x = axis_string(proj_cf.X)
	local str_y, sign_y = axis_string(proj_cf.Y)
	local str_z, sign_z = axis_string(proj_cf.Z)
	local mat_string = tostring(material or 'Plastic'):match '[^\\.]+$'
	local coords = string.format(
		'%s %s %s/%s', str_x, str_y, str_z, rot_string(cf))
	return game.ReplicatedStorage.Sockets.Edit.Place:InvokeServer(
		coords, {
			['CanCollide'] = true,
			['Color'] = colour,
			['LightColor'] = Color3.fromRGB(242, 243, 243),
			['Size'] = size_num(sign_x, sign_y, sign_z),
			['Material'] = MATERIALS[mat_string],
			['Shape'] = SHAPES[shape or 'Block'],
			['Transparency'] = 0,
			['Reflectance'] = .6,
			['Light'] = 0,
		})
end

function CLEAR_BLOCKS()
	game.ReplicatedStorage.Sockets.World.LoadTemplate:FireServer 'Scratch'
	task.wait(5)
	return true
end

function BLOCK_EXISTS(o) return o and o.Parent end

function REMOVE_BLOCK(o)
	game.ReplicatedStorage.Sockets.Edit.Delete:FireServer(o)
	return true
end

BLOCK_CHUNK_SIZE = 69
BLOCK_CHUNK_PERIOD = 2

-- Won't make much sense since CFrame position are shown 1/4 of what they really are.
local function grid(x, y, z) return CFrame.new(x, y, z) end

_E.EXEC'lib-build'
-- #endregion

-- game.ReplicatedStorage.Sockets.Edit.EditBlock:FireServer("motele", {game.Workspace.Blocks.Block, game.Workspace.Blocks.Block})

-- game.ReplicatedStorage.Sockets.Edit.EditBlock:FireServer("movable", {game.Workspace.Blocks.Cube, "force", {"!movable", "force", "10000", "11000", "0"}})

-- game.ReplicatedStorage.Sockets.Edit.EditBlock:FireServer("movable", {game.Workspace.Blocks.Cube, "ridable", {"!movable", "ridable"}})

-- game.ReplicatedStorage.Sockets.Edit.EditBlock:FireServer("cannon", {game.Workspace.Blocks.Block, 69, Enum.NormalId.Front})

--[[
print(reset())
local t = {}
local l = {}
for f = 0, 69 do
	for i = -f, f - 1 do
		table.insert(l, {f, i, f})
		table.insert(l, {f, f, -i})
		table.insert(l, {f, -f, i})
		table.insert(l, {f, -i, -f})
	end
end
for _, e in next, l do
	local f, x, z = unpack(e)
	local m = math.clamp(3 * (f - 13), 3, 13)
	local r = m * math.noise(x / 13, 2, z / 13)
	local h = 0.25 * math.round(r)
	if h % 1 == .5 then h = h + math.random(0, 1) * 0.25 - 0.5 end
	if h % 1 ~= 0 and m > 5 then h = math.round(h) end
	table.insert(t, grid(x, h, z))
end
make(t, Color3.new(1, 1, 1), 'Glass')
]]

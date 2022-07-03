---@diagnostic disable: undefined-global
-- #region
local MATERIALS = {}
local SHAPES = {}
local SIZES = {}
local gui = game.Players.LocalPlayer.PlayerGui.MainGUI.ScreenGui
for dd_i, dd in next, gui:children() do
	local t = {}
	local options = dd:findFirstChild('Content', true)
	if options then for op_i, op in options:children() do t[op.Text] = op_i end end
	if t['Plastic'] then
		MATERIALS = t
	elseif t['Block'] then
		SHAPES = t
	elseif t['Full'] then
		SIZES = t
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
	end
end

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
local function size_num(sx, sy, sz) return SIZES[SIZE_MAP[sx][sy][sz]] end

function ADD_BLOCK(cf, colour, material, shape)
	local str_x, sign_x = axis_string(cf.X)
	local str_y, sign_y = axis_string(cf.Y)
	local str_z, sign_z = axis_string(cf.Z)
	local mat_string = tostring(material):match '[^\\.]+$'
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
			['Reflectance'] = 0,
			['Light'] = 0,
		})
end

function CLEAR_BLOCKS()
	game.ReplicatedStorage.Sockets.World.LoadTemplate:FireServer('Scratch')
	wait(5)
	return true
end

function BLOCK_EXISTS(o) return o and o.Parent end

function REMOVE_BLOCK(o)
	game.ReplicatedStorage.Sockets.Edit.Delete:FireServer(o)
	return true
end

BLOCK_CHUNK_SIZE = 69
BLOCK_CHUNK_PERIOD = 7

-- Won't make much sense since CFrame position are shown 1/4 of what they really are.
local function grid(x, y, z) return CFrame.new(x, y, z) end

exec'lib-build'
-- #endregion

print(reset())
local L = 6969
for i = 1, L - 1 do
	spawn(function() make({grid(0, 0, i * 1.5)}, Color3.fromHSV(i / L, 1, 1)) end)
end

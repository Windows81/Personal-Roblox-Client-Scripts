---@diagnostic disable: undefined-global
-- #region
local MATERIALS = {
	'Plastic',
	'Brick',
	'Cobblestone',
	'Concrete',
	'CorrodedMetal',
	'DiamondPlate',
	'Fabric',
	'Foil',
	'Granite',
	'Grass',
	'Ice',
	'Marble',
	'Metal',
	'Neon',
	'Glass',
	'Pebble',
	'SmoothPlastic',
	'Sand',
	'Slate',
	'Wood',
	'WoodPlanks',
	'ForceField',
	'Asphalt',
	'Basalt',
	'CrackedLava',
	'Glacier',
	'Ground',
	'LeafyGrass',
	'Limestone',
	'Mud',
	'Pavement',
	'Rock',
	'Salt',
	'Sandstone',
	'Snow',
}
function ADD_BLOCK(cf, colour)
	return game.ReplicatedStorage.Sockets.Edit.Place:InvokeServer(
		string.format(
			'%d %d %d/0', cf.X, cf.Y, cf.Z), {
			['Reflectance'] = 0,
			['CanCollide'] = true,
			['Color'] = colour,
			['LightColor'] = Color3.fromRGB(242, 243, 243),
			['Transparency'] = 0,
			['Size'] = 1,
			['Material'] = 15,
			['Shape'] = 1,
			['Light'] = 0,
		})
end

function BLOCK_EXISTS(o) return o and o.Parent end

function REMOVE_BLOCK(o)
	game.ReplicatedStorage.Sockets.Edit.Delete:FireServer(o)
	return true
end

-- Won't make much sense since CFrame position are shown 1/4 of what they really are.
local function grid(x, y, z) return CFrame.new(x, y, z) end

exec'lib-build'
-- #endregion

print(reset())
local L = 69 * 13
for i = 1, L do
	make({grid(0, 0, i * 1.5)}, Color3.fromHSV(i / L, 1, 1))
	if i % 69 == 0 then wait(7) end
end

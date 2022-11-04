local EVENTS = game.ReplicatedStorage.EventStorage
local E_REMOVE_ALL = EVENTS:FindFirstChild 'RemoveAll'
local E_REMOVE = EVENTS:FindFirstChild 'Remove'
local E_PLACE = EVENTS:FindFirstChild 'Place'

function ADD_BLOCK(cf, colour, material)
	E_PLACE:InvokeServer(
		{ --
			['Color'] = colour,
			['Material'] = material,
			['Position'] = cf.Position,
		})
end

function CLEAR_BLOCKS()
	E_REMOVE_ALL:FireServer()
	task.wait(3)
	return true
end

function BLOCK_EXISTS(o)
	print(o:GetFullName())
	return o and o.Parent
end

function REMOVE_BLOCK(o)
	E_REMOVE:InvokeServer(o)
	return true
end

function WAIT_FOR_BLOCK()
	local o = game.Workspace.Builds.ChildAdded:Wait()
	return o.CFrame, o
end

BLOCK_CHUNK_SIZE = 69
BLOCK_CHUNK_PERIOD = 1

if _E then _E.EXEC'lib-build' end
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

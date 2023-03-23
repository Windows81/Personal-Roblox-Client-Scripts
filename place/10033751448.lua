--[==[HELP]==
To be used with "Build and Battle" by PlayMore Studios.
]==] --
--
local REMOTES = game.ReplicatedStorage.Remotes

local TYPES = {}
getrenv().INSERT_TYPES = TYPES
for _, cat in next, game.StarterPack['1 Stamp'].Categories:children() do
	for _, pag in next, cat:children() do
		for _, obj in next, pag:children() do
			TYPES[obj.AssetName.Value] = obj.AssetId.Value
		end
	end
end

local cached_plate
local function check_plate(pl) return pl.Owner.Value == game.Players.LocalPlayer end
local function get_plate()
	if cached_plate and check_plate(cached_plate) then return cached_plate end
	for _, pl in next, game.Workspace.Plates:children() do
		if check_plate(pl) then
			cached_plate = pl
			return pl
		end
	end
end

function ADD_BLOCK(cf, typ)
	local pos = CFrame.new(cf.Position)
	local rot = math.round(select(2, cf:ToEulerAnglesYXZ()) / (math.pi / 2)) % 4
	local uuid = '{f8aca18f-063c-4e9f-9ae2-247d83cd51c6}'
	return REMOTES.StampAsset:InvokeServer(TYPES[typ], pos, uuid, {}, rot)
end

function CLEAR_BLOCKS()
	game.Players:Chat ':clear'
	task.wait(1)
end

BLOCK_EVENT = get_plate().ActiveParts.ChildAdded
function CHECK_BLOCK(o)
	local cfp = o:WaitForChild('PlacementCFrame', 69)
	print('Object', o, cfp)
	return cfp.Value
end

function DELETE_BLOCK(o) return REMOTES.DeleteAsset:InvokeServer(o) end

function BLOCK_EXISTS(o) return o and o:FindFirstChildWhichIsA('BasePart', true) end

if _E then _E.EXEC'lib-build' end

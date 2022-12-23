local framework = game.ReplicatedStorage.Framework
local REMOTES = framework.Modules.Shared.Internal.Networking['2  •  Remote']

local TYPES = {}
getrenv().INSERT_TYPES = TYPES
for _, res in next, framework.Resources.Instances.Blocks:children() do
	TYPES[res.Name] = true
end

function ADD_BLOCK(cf, typ)
	local pos = cf.Position
	local rot = math.deg(select(2, cf:ToEulerAnglesYXZ()))
	local s, o = REMOTES.RemoteFunction:InvokeServer(
		'S_Building_Build', typ, pos, rot)
	print(666)
	return s, o
end

function REMOVE_BLOCKS(t)
	return REMOTES.RemoteFunction:InvokeServer('S_Deleting_Delete', t)
end

BLOCK_CHUNK_SIZE = 1
BLOCK_CHUNK_PERIOD = 0.1

if _E then _E.EXEC'lib-build' end
--[==[
ml
local p=Vector3.new(0, 24, 0)
local B=4
local W1=6
local W2=13
local H=4
local S=7
local h={
	['Yellow Stairs']={CFrame.new(p+B*Vector3.new(0,0,1))*CFrame.Angles(0,-math.pi/2,0)},
}
for p,t in next,h do make(t,p) end
local t={
	box3(p+B*Vector3.new(0,0,1),B,0,2,0),
}
for _,g in next,t do void(g) end
local h={
	['Glass Block']=join(
		box3(p+B*Vector3.new(1, 1/4,1),B,W1-3,0,W2-3)
	),
	['Green Block']=join(
		frme(p+B*Vector3.new(0, 0/1,0),B,W1-1,0,W2-1),
		frme(p+B*Vector3.new(0, 1/1,0),B,W1-1,0,W2-1),
		frme(p+B*Vector3.new(0, 1/1,0),B,W1-1,0,W2-1),
		frme(p+B*Vector3.new(0, 2/1,0),B,W1-1,0,W2-1),
		frme(p+B*Vector3.new(0, 3/1,0),B,W1-1,0,W2-1),
		frme(p+B*Vector3.new(0, 4/1,0),B,W1-1,0,W2-1)
	),
	['Red Slab']=join(
		box3(p+B*Vector3.new(1,15/4,1),B,W1-3,0,W2-3)
	),
	['Yellow Slab']=join(
		box3(p+B*Vector3.new(1, 1/4,1),B,W1-3,0,W2-3)
	),
}
for p,t in next,h do make(box3(t,H*B,0,S-1,0),p) end
local h={
}
for p,t in next,h do make(shft(t,CFrame.new(0,H*(S-1)*B,0)),p) end


]==]

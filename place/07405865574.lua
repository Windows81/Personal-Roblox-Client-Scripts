local REMOTES = game.ReplicatedStorage.Remotes

function ADD_BLOCK(cf, typ)
	local pos = cf.Position
	local rot_deg = {}
	for i, r in next, {cf:ToEulerAnglesYXZ()} do rot_deg[i] = math.deg(r) end
	return REMOTES.Placed:InvokeServer(typ, pos, Vector3.new(unpack(rot_deg))), pos
end

function REMOVE_BLOCK(pos)
	return game.ReplicatedStorage.Remotes.Destroyed:InvokeServer(pos)
end

function BLOCK_EXISTS(o) return true end

BLOCK_TIMEOUT = 5
BLOCK_CHUNK_SIZE = 13

if _E then _E.EXEC'lib-build' end

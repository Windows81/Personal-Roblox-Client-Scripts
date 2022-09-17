_G.msg_cc = game.Workspace.CurrentCamera
_G.msg_cc.CameraType = 'Scriptable'
_G.msg = function(m)
	print(m)
	local s = m:split(' ')
	if #s ~= 6 then return end
	for i, v in next, s do
		local n = tonumber(v)
		if not n then return end
		s[i] = n
	end
	local v1, v2, v3, v4, v5, v6 = unpack(s)
	_G.msg_cc.CFrame = CFrame.new(Vector3.new(v1, v2, v3), Vector3.new(v4, v5, v6))
end

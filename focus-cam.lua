local rs = game:GetService 'RunService'

local args = _E.ARGS
local BASE = args[1]
local FOCUS = args[2]

local function to_v3(v)
	if typeof(v) == 'CFrame' then
		return v.Position
	elseif typeof(v) == 'Vector3' then
		return v
	elseif v:isA 'Model' then
		return v:GetPivot().Position
	elseif v:isA 'BasePart' then
		return v.Position
	end
end

local function cleanup()
	local cc = game.Workspace.CurrentCamera
	cc.CameraType = Enum.CameraType.Custom
	cc.FieldOfView = 70
	_G.foc_evt:Disconnect()
	_G.foc_evt = nil
end
if _G.foc_evt then cleanup() end

if BASE then
	_G.foc_evt = rs.RenderStepped:Connect(
		function()
			local v1 = to_v3(BASE)
			local v2 = to_v3(FOCUS)
			local cc = game.Workspace.CurrentCamera
			cc.CameraType = Enum.CameraType.Scriptable
			cc.FieldOfView = 70 - math.log((v2 - v1).Magnitude, 1.15)
			cc.CFrame = CFrame.new(v1, v2)
		end)
end

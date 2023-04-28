--[==[HELP]==
Interpolates the current camera between an array of positions, over a duration of time.

[1] - {BasePart | CFrame | Vector3 | false} | number | nil
	The domain of points to which the camera can interpolate.
	If argument is set to a positive integer, the number of keyframes that are captured by clicking the screen.
	If entry in table is set to 'false' or 'nil', task.wait for user click to retrieve current camera CFrame.
	If nil, default to 3.

[2] - number | nil
	The total duration for the interpolation process.
	Defaults to (#VALUES - 1) * 5.
]==] --
--
local args = _E and _E.ARGS or {}
local VALUES = args[1] or 3
if type(VALUES) == 'number' then VALUES = table.create(VALUES, false) end
local DURATION = args[2] or (#VALUES - 1) * 5

-- https://github.com/0J3/CutsceneService/blob/a4666f0683e37607f2f8dc591808db58c12cf98a/src/CutsceneService/init.lua#L109
local function getCF(pointsTB, ratio)
	repeat
		local ntb = {}
		for i, p in next, pointsTB do
			if i ~= 1 then ntb[i - 1] = pointsTB[i - 1]:Lerp(p, ratio) end
		end
		pointsTB = ntb
	until #pointsTB == 1
	return pointsTB[1]
end

local rs = game:GetService 'RunService'
if _G.flcm_e then _G.flcm_e:Disconnect() end
local m = game.Players.LocalPlayer:GetMouse()
local cc = game.Workspace.CurrentCamera

local points = {}
for i, v in next, VALUES do
	local cf
	local t = typeof(v)
	if not v then
		m.Button1Up:Wait()
		cf = cc.CFrame
		print('CFRAME LOGGED FOR FLYCAM:', cf)
	elseif t == 'Instance' then
		if v:isA 'BasePart' then
			cf = v.CFrame
		elseif v:isA 'Model' then
			cf = v:GetPivot()
		end
	elseif t == 'Vector3' then
		if i > 1 then
			cf = CFrame.new(v, v - (points[i - 1].Position - v))
		else
			cf = CFrame.new(v)
		end
	elseif t == 'CFrame' then
		cf = v
	end
	table.insert(points, cf)
end

local start = tick()
local t = cc.CameraType
cc.CameraType = Enum.CameraType.Scriptable
_G.flcm_e = rs.RenderStepped:Connect(
	function()
		local e = tick() - start
		local r = e / DURATION
		if e >= DURATION then
			_G.flcm_e:Disconnect()
			cc.CameraType = t
			return
		end
		local cf = getCF(points, r)
		cc.CoordinateFrame = cf
		cc.Focus = cf * CFrame.new(0, 0, -1)
	end)

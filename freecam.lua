-- Modified from https://pastebin.com/3wrbwSz4
-- Tested with JJSploit and should work with Synapse X, Protosmasher, etc. (not tested).
local MOVE_KEYS = {
	[Enum.KeyCode.D] = Vector3.new(01, 0, 0),
	[Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
	[Enum.KeyCode.S] = Vector3.new(0, 0, 01),
	[Enum.KeyCode.W] = Vector3.new(0, 0, -1),
	[Enum.KeyCode.E] = Vector3.new(0, 1, 0),
	[Enum.KeyCode.Q] = Vector3.new(0, -1, 0),

	[Enum.KeyCode.Right] = Vector3.new(1, 0, 0),
	[Enum.KeyCode.Left] = Vector3.new(-1, 0, 0),
	[Enum.KeyCode.Down] = Vector3.new(0, 0, 1),
	[Enum.KeyCode.Up] = Vector3.new(0, 0, -1),
	[Enum.KeyCode.PageUp] = Vector3.new(0, 1, 0),
	[Enum.KeyCode.PageDown] = Vector3.new(0, -1, 0),
}

local NORMAL_SPEED = 30
local SPRINT_SPEED = 90
local TOGGLE_KEY = Enum.KeyCode.Comma
local SPRINT_KEY = Enum.KeyCode.LeftBracket
local FOV_KEY = Enum.KeyCode.RightBracket
local SENSITIVITY = Vector2.new(1 / 128, 1 / 128)

local uis = game:GetService('UserInputService')
local pl = game.Players.LocalPlayer
local cam = game.Workspace.CurrentCamera
local mouse = pl:GetMouse()
local debounce = false

local movePosition = Vector2.new(0, 0)
local targetMovePosition = movePosition
local lastRightButtonDown = Vector2.new(0, 0)
local rightMouseButtonDown = false

local speed = NORMAL_SPEED
local fov = cam.FieldOfView

local keys_dn = {}

function lerp(a, b, t)
	if t == 1 then
		return b
	else
		if tonumber(a) then
			return a * (1 - t) + (b * t)
		else
			return a:Lerp(b, t)
		end
	end
end

uis.InputChanged:Connect(
	function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			local d = Vector2.new(inputObject.Delta.X, inputObject.Delta.Y)
			movePosition = movePosition + d
		end
	end)

function calc_mv(k, m)
	local v = Vector3.new()
	for i, _ in next, k do v = v + (MOVE_KEYS[i] or Vector3.new()) end
	return CFrame.new(v * m)
end

function Round(num, numDecimalPlaces)
	return math.floor((num / numDecimalPlaces) + .5) * numDecimalPlaces
end

function input(i, pr)
	if pr then return end
	if MOVE_KEYS[i.KeyCode] then
		if i.UserInputState == Enum.UserInputState.Begin then
			keys_dn[i.KeyCode] = true
		elseif i.UserInputState == Enum.UserInputState.End then
			keys_dn[i.KeyCode] = nil
		end
	else
		if i.UserInputState == Enum.UserInputState.Begin then
			if i.UserInputType == Enum.UserInputType.MouseButton2 then
				rightMouseButtonDown = true
				lastRightButtonDown = Vector2.new(mouse.X, mouse.Y)
				uis.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			elseif i.KeyCode == FOV_KEY then
				fov = 20
			elseif i.KeyCode == SPRINT_KEY then
				speed = SPRINT_SPEED
			end
		else
			if i.UserInputType == Enum.UserInputType.MouseButton2 then
				rightMouseButtonDown = false
				uis.MouseBehavior = Enum.MouseBehavior.Default
			elseif i.KeyCode == FOV_KEY then
				fov = 70
			elseif i.KeyCode == SPRINT_KEY then
				speed = NORMAL_SPEED
			end
		end
	end
end

if _G.freecam_wf then _G.freecam_wf:Disconnect() end
if _G.freecam_wb then _G.freecam_wb:Disconnect() end
if _G.freecam_ib then _G.freecam_ib:Disconnect() end
if _G.freecam_ie then _G.freecam_ie:Disconnect() end

_G.freecam_wf = mouse.WheelForward:Connect(
	function() cam.CoordinateFrame = cam.CoordinateFrame * CFrame.new(0, 0, -5) end)

_G.freecam_wb = mouse.WheelBackward:Connect(
	function() cam.CoordinateFrame = cam.CFrame * CFrame.new(0, 0, 5) end)

_G.freecam_ib = uis.InputBegan:Connect(
	function(i, pr)
		if pr then
			return
		elseif MOVE_KEYS[i.KeyCode] then
			keys_dn[i.KeyCode] = true
		elseif debounce and i.UserInputType == Enum.UserInputType.MouseButton2 then
			rightMouseButtonDown = true
			lastRightButtonDown = Vector2.new(mouse.X, mouse.Y)
			uis.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		elseif i.KeyCode == FOV_KEY then
			fov = 20
		elseif i.KeyCode == SPRINT_KEY then
			speed = SPRINT_SPEED
		elseif i.KeyCode == TOGGLE_KEY then
			debounce = not debounce
			if debounce then
				pl.Character.Humanoid.WalkSpeed = 0
				cam.CameraType = Enum.CameraType.Scriptable
			else
				pl.Character.Humanoid.WalkSpeed = 16
				cam.CameraSubject = pl.Character.Humanoid
				cam.CameraType = Enum.CameraType.Custom
			end
		end
	end)

_G.freecam_ie = uis.InputEnded:Connect(
	function(i, pr)
		if pr then
			return
		elseif MOVE_KEYS[i.KeyCode] then
			keys_dn[i.KeyCode] = nil
		elseif debounce and i.UserInputType == Enum.UserInputType.MouseButton2 then
			rightMouseButtonDown = false
			uis.MouseBehavior = Enum.MouseBehavior.Default
		elseif i.KeyCode == FOV_KEY then
			fov = 70
		elseif i.KeyCode == SPRINT_KEY then
			speed = NORMAL_SPEED
		end
	end)

if _G.freecam_step then _G.freecam_step:Disconnect() end
_G.freecam_step = game:GetService 'RunService'.RenderStepped:Connect(
	function(d)
		if not debounce then return end
		targetMovePosition = movePosition
		local ty = -targetMovePosition.Y * SENSITIVITY.Y
		local tx = -targetMovePosition.X * SENSITIVITY.X
		local eu = CFrame.fromEulerAnglesYXZ(ty, tx, 0)
		local mv = calc_mv(keys_dn, speed * d)

		cam.CFrame = CFrame.new(cam.CFrame.Position) * eu * mv
		cam.FieldOfView = fov

		if rightMouseButtonDown then
			uis.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			local rv = Vector2.new(mouse.X, mouse.Y)
			movePosition = movePosition - (lastRightButtonDown - rv)
			lastRightButtonDown = rv
		end
	end)

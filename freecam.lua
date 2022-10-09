--[==[HELP]==
Modified from https://pastebin.com/3wrbwSz4
Tested with JJSploit and should work with Synapse X, Protosmasher, etc. (not tested).

Type ',' to toggle freecam mode.
Hold '[' to sprint.
Hold ']' to reduce field of view.

[1] - number | nil
	The base speed at which to pan; defaults to 31.

[2] - number | nil
	The speed at which to pan when '[' is held; defaults to 211.
]==] --
--
local args = _E and _E.ARGS or {}
local NORMAL_SPEED = args[1] or 31
local SPRINT_SPEED = args[2] or 211
local TOGGLE_KEY = Enum.KeyCode.Comma
local SPRINT_KEY = Enum.KeyCode.LeftBracket
local FOV_KEY = Enum.KeyCode.RightBracket
local SENSITIVITY = Vector2.new(1 / 128, 1 / 128)
local WASD_MULT = 2
local ARROW_MULT = 1

local MOVE_KEYS = {
	[Enum.KeyCode.D] = Vector3.new(WASD_MULT, 0, 0),
	[Enum.KeyCode.A] = Vector3.new(-WASD_MULT, 0, 0),
	[Enum.KeyCode.S] = Vector3.new(0, 0, WASD_MULT),
	[Enum.KeyCode.W] = Vector3.new(0, 0, -WASD_MULT),
	[Enum.KeyCode.E] = Vector3.new(0, WASD_MULT, 0),
	[Enum.KeyCode.Q] = Vector3.new(0, -WASD_MULT, 0),

	[Enum.KeyCode.Right] = Vector3.new(ARROW_MULT, 0, 0),
	[Enum.KeyCode.Left] = Vector3.new(-ARROW_MULT, 0, 0),
	[Enum.KeyCode.Down] = Vector3.new(0, 0, ARROW_MULT),
	[Enum.KeyCode.Up] = Vector3.new(0, 0, -ARROW_MULT),
	[Enum.KeyCode.PageUp] = Vector3.new(0, ARROW_MULT, 0),
	[Enum.KeyCode.PageDown] = Vector3.new(0, -ARROW_MULT, 0),
}

local uis = game:GetService 'UserInputService'
local pl = game.Players.LocalPlayer
local cam = game.Workspace.CurrentCamera
local mouse = pl:GetMouse()
local enabled = false

local curr_mouse_rot = Vector2.new(0, 0)
local prev_mouse_rot = curr_mouse_rot
local button2_ref = Vector2.new(0, 0)
local button2_dn = false

local speed = NORMAL_SPEED
local fov = cam.FieldOfView
local keys_dn = {}

function set_enabled(b)
	if enabled == b then return end
	enabled = b
	if enabled then
		pl.Character.Humanoid.WalkSpeed = 0
		cam.CameraType = Enum.CameraType.Scriptable
	else
		pl.Character.Humanoid.WalkSpeed = 16
		cam.CameraSubject = pl.Character.Humanoid
		cam.CameraType = Enum.CameraType.Custom
	end
end

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
			curr_mouse_rot = curr_mouse_rot + d
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

if _G.freecam_wf then _G.freecam_wf:Disconnect() end
if _G.freecam_wb then _G.freecam_wb:Disconnect() end
if _G.freecam_ib then _G.freecam_ib:Disconnect() end
if _G.freecam_ie then _G.freecam_ie:Disconnect() end

_G.freecam_wf = mouse.WheelForward:Connect(
	function() cam.CFrame = cam.CFrame * CFrame.new(0, 0, -5) end)

_G.freecam_wb = mouse.WheelBackward:Connect(
	function() cam.CFrame = cam.CFrame * CFrame.new(0, 0, 5) end)

_G.freecam_ib = uis.InputBegan:Connect(
	function(i, pr)
		if pr then
			return
		elseif MOVE_KEYS[i.KeyCode] then
			keys_dn[i.KeyCode] = true
		elseif enabled and i.UserInputType == Enum.UserInputType.MouseButton2 then
			button2_dn = true
			button2_ref = Vector2.new(mouse.X, mouse.Y)
			uis.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		elseif i.KeyCode == FOV_KEY then
			fov = 20
		elseif i.KeyCode == SPRINT_KEY then
			speed = SPRINT_SPEED
		elseif i.KeyCode == TOGGLE_KEY then
			set_enabled(not enabled)
		end
	end)

_G.freecam_ie = uis.InputEnded:Connect(
	function(i, pr)
		if pr then
			return
		elseif MOVE_KEYS[i.KeyCode] then
			keys_dn[i.KeyCode] = nil
		elseif enabled and i.UserInputType == Enum.UserInputType.MouseButton2 then
			button2_dn = false
			uis.MouseBehavior = Enum.MouseBehavior.Default
		elseif i.KeyCode == FOV_KEY then
			fov = 70
		elseif i.KeyCode == SPRINT_KEY then
			speed = NORMAL_SPEED
		end
	end)

local rs = game:GetService 'RunService'
if _G.freecam_step then rs:UnbindFromRenderStep(_G.freecam_step) end
_G.freecam_step = 'freecam'
rs:BindToRenderStep(
	_G.freecam_step, Enum.RenderPriority.Camera.Value, function(d)
		if not enabled then return end
		prev_mouse_rot = curr_mouse_rot
		local ty = -prev_mouse_rot.Y * SENSITIVITY.Y
		local tx = -prev_mouse_rot.X * SENSITIVITY.X
		local eu = CFrame.fromEulerAnglesYXZ(ty, tx, 0)
		local mv = calc_mv(keys_dn, speed * d)

		cam.CFrame = CFrame.new(cam.CFrame.Position) * eu * mv
		cam.FieldOfView = fov

		if button2_dn then
			uis.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			local rv = Vector2.new(mouse.X, mouse.Y)
			curr_mouse_rot = curr_mouse_rot - (button2_ref - rv)
			button2_ref = rv
		end
	end)

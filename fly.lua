--[==[HELP]==
Attaches a BodyGyro and RocketPropulsion object to the current character.
If the character dies, under default conditions, these objects are reloaded automatically
.
Strike 'H' to toggle flying.
Strike 'G' to toggle anchoring the root part.
Strike 'L' to go faster by a factor of 3/2.
Strike 'K' to slow down by a factor of 2/3.

[1] - number | nil
	Determines the initial speed at which the character is to fly.
	Corresponds to internal variable SPEED.  Default is 127.

[2] - bool | nil
	If true, calculates rotation relative to the character, rather than to the current camera.
	Corresponds to internal variable REL_TO_CHAR.

[3] - number | nil
	Determines the maximum amount of torque that the RocketPropulsion may exert to rotate the character.
	Corresponds to internal variable MAX_TORQUE_RP.  Defaults to 1e4.

[4] - number | nil
	Determines how aggressive of a force is applied by the RocketPropulsion.
	Corresponds to internal variable THRUST_P.  Defaults to 1e5.

[5] - number | nil
	Determines the maximum amount of thrust that will be exerted to move the character.
	Corresponds to internal variable MAX_THRUST.  Defaults to 5e5.

[6] - number | nil
	Determines the limit on how much torque that may be applied to all axes by the BodyGyro.
	Corresponds to internal variable MAX_TORQUE_BG.  Defaults to 3e4.

[7] - number | nil
	Determines the amount of dampening that to use by the RocketPropulsion.
	Corresponds to internal variable THRUST_D.  Defaults to 1e5.

[8] - number | nil
	Determines the amount of dampening that the RocketPropulsion is to use.
	Corresponds to internal variable TURN_D.  Defaults to 2e2.

[9] - Instance | nil
	The part to which the RocketPropulsion and BodyGyro are both attached.
	Corresponds to internal variable ROOT_PART.
	If nil, defaults to the player's character, which is automatically initialised upon respawn.
]==] --
--
local args = _E and _E.ARGS or {}
local FLYK = Enum.KeyCode.H
local ANCK = Enum.KeyCode.G
local FSTK = Enum.KeyCode.L
local SLWK = Enum.KeyCode.K

local MVKS = {
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

local SPEED = args[1]
if SPEED == nil then SPEED = 127 end

local REL_TO_CHAR = args[2]
if REL_TO_CHAR == nil then REL_TO_CHAR = false end

local MAX_TORQUE_RP = args[3]
if MAX_TORQUE_RP == nil then MAX_TORQUE_RP = 1e4 end

local THRUST_P = args[4]
if THRUST_P == nil then THRUST_P = 1e5 end

local MAX_THRUST = args[5]
if MAX_THRUST == nil then MAX_THRUST = 5e5 end

local MAX_TORQUE_BG = args[6]
if MAX_TORQUE_BG == nil then MAX_TORQUE_BG = 3e4 end

local THRUST_D = args[7]
if THRUST_D == nil then THRUST_D = math.huge end

local TURN_D = args[8]
if TURN_D == nil then TURN_D = 2e2 end

local ROOT_PART = args[9]
local keys_dn = {}
local flying = false
local enabled = false
local move_dir = Vector3.new()
local uis = game:GetService 'UserInputService'
local lp = game.Players.LocalPlayer
local ms = lp:GetMouse()
local humanoid
local parent

if _G.fly_evts then for _, e in next, _G.fly_evts do e:Disconnect() end end
if _G.fly_rp then _G.fly_rp:Destroy() end
if _G.fly_bg then _G.fly_bg:Destroy() end
if args[1] == false then return end

local function init()
	if ROOT_PART then
		parent = ROOT_PART
		local model = parent:FindFirstAncestorWhichIsA 'Model'
		if model then humanoid = model:FindFirstAncestorWhichIsA 'Humanoid' end
	else
		local ch = lp.Character
		humanoid = ch:WaitForChild 'Humanoid'
		parent = humanoid.RootPart
	end

	if _G.fly_rp then _G.fly_rp:Destroy() end
	if _G.fly_bg then _G.fly_bg:Destroy() end

	local rp_h = MAX_TORQUE_RP
	_G.fly_bg = Instance.new('BodyGyro', parent)
	_G.fly_rp = Instance.new('RocketPropulsion', parent)
	local md = Instance.new('Model', _G.fly_pt)
	_G.fly_pt = Instance.new('Part', md)
	_G.fly_rp.MaxTorque = Vector3.new(rp_h, rp_h, rp_h)
	_G.fly_bg.MaxTorque = Vector3.new()
	md.PrimaryPart = _G.fly_pt
	_G.fly_pt.Anchored = true
	_G.fly_pt.CanCollide = false
	_G.fly_rp.CartoonFactor = 1
	_G.fly_rp.Target = _G.fly_pt
	_G.fly_rp.MaxSpeed = SPEED
	_G.fly_rp.MaxThrust = MAX_THRUST
	_G.fly_rp.ThrustP = THRUST_P
	_G.fly_rp.ThrustD = THRUST_D
	_G.fly_rp.TurnP = THRUST_P
	_G.fly_rp.TurnD = TURN_D
	_G.fly_bg.P = 3e4
	enabled = false
end

local function fly_dir()
	if REL_TO_CHAR then
		front = parent.CFrame.LookVector
	else
		-- local rx = .5 - ms.Y / ms.ViewSizeY
		-- local ry = .5 - ms.X / ms.ViewSizeX
		-- front = (game.Workspace.CurrentCamera.CFrame * CFrame.fromEulerAnglesYXZ(rx, ry, 0)).LookVector
		front = game.Workspace.CurrentCamera:ScreenPointToRay(ms.X, ms.Y).Direction
	end
	return CFrame.new(Vector3.new(), front) * move_dir
end

_G.fly_evts = {
	lp.CharacterAdded:Connect(init),
	uis.InputBegan:Connect(
		function(i, p)
			if p then
				return
			elseif i.KeyCode == FLYK then
				enabled = not enabled
				if enabled then
					if _G.fly_bg then --
						local bg_h = MAX_TORQUE_BG
						_G.fly_bg.MaxTorque = Vector3.new(bg_h, 0, bg_h)
					end
					if _G.fly_rp then --
						local rp_h = MAX_TORQUE_RP
						_G.fly_rp.MaxTorque = Vector3.new(rp_h, rp_h, rp_h)
					end
				else
					if _G.fly_bg then --
						_G.fly_bg.MaxTorque = Vector3.new()
					end
					if _G.fly_rp then --
						_G.fly_rp.MaxTorque = Vector3.new()
					end
				end

			elseif i.KeyCode == ANCK then
				parent.Anchored = not parent.Anchored

			elseif i.KeyCode == FSTK then
				SPEED = SPEED * (3 / 2)
				_G.fly_rp.MaxSpeed = SPEED

			elseif i.KeyCode == SLWK then
				SPEED = SPEED / (3 / 2)
				_G.fly_rp.MaxSpeed = SPEED

			elseif MVKS[i.KeyCode] and not keys_dn[i.KeyCode] then
				move_dir = move_dir + MVKS[i.KeyCode]
				keys_dn[i.KeyCode] = true
			end
		end),
	uis.InputEnded:Connect(
		function(i, p)
			if p then
				return
			elseif MVKS[i.KeyCode] and keys_dn[i.KeyCode] then
				move_dir = move_dir - MVKS[i.KeyCode]
				keys_dn[i.KeyCode] = nil
			end
		end),
	game:GetService 'RunService'.RenderStepped:Connect(
		function()
			if not _G.fly_rp or not parent then return end
			local do_fly = enabled and move_dir.Magnitude > 0
			if flying ~= do_fly then
				flying = do_fly
				if humanoid then humanoid.AutoRotate = not do_fly end
				if not do_fly then
					parent.Velocity = Vector3.new()
					_G.fly_rp:Abort()
					return
				end
				_G.fly_rp:Fire()
			end
			_G.fly_pt.Position = parent.Position + 0x1000 * fly_dir()
		end),
}
init()

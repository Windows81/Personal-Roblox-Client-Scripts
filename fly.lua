local args = _G.EXEC_ARGS or {}
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

local speed = args[1] or 666
local rel_to_char = args[2] or false
local max_torque_rp = args[3] or 1e4
local thrust_p = args[4] or 1e7
local max_thrust = args[5] or 5e5
local max_torque_bg = args[6] or 3e4
local thrust_d = args[7] or math.huge
local turn_p = args[8] or 1e5
local turn_d = args[9] or 2e2

local keys_dn = {}
local flying = false
local enabled = false
local move_dir = Vector3.new()
local uis = game:GetService 'UserInputService'
local lp = game.Players.LocalPlayer
local ms = lp:GetMouse()
if _G.fly_rp then _G.fly_rp:Destroy() end
if _G.fly_bg then _G.fly_bg:Destroy() end
if _G.fly_evts then for _, e in next, _G.fly_evts do e:Disconnect() end end

local function init()
	local ch = lp.Character
	local hrp = ch:WaitForChild 'HumanoidRootPart'
	_G.fly_bg = Instance.new('BodyGyro', hrp)
	_G.fly_rp = Instance.new('RocketPropulsion', hrp)
	local md = Instance.new('Model', _G.fly_pt)
	_G.fly_pt = Instance.new('Part', md)
	_G.fly_rp.MaxTorque = Vector3.new(max_torque_rp, max_torque_rp, max_torque_rp)
	_G.fly_bg.MaxTorque = Vector3.new()
	md.PrimaryPart = _G.fly_pt
	_G.fly_pt.Anchored = true
	_G.fly_pt.CanCollide = false
	_G.fly_rp.CartoonFactor = 1
	_G.fly_rp.Target = _G.fly_pt
	_G.fly_rp.MaxSpeed = math.abs(speed)
	_G.fly_rp.MaxThrust = max_thrust
	_G.fly_rp.ThrustP = thrust_p
	_G.fly_rp.ThrustD = thrust_d
	_G.fly_rp.TurnP = turn_p
	_G.fly_rp.TurnD = turn_d
	_G.fly_bg.P = 3e4
	enabled = false
end

local function fly_dir()
	if rel_to_char then
		front = _G.fly_rp.Parent.CFrame.LookVector
	else
		front = game.workspace.CurrentCamera:ScreenPointToRay(ms.X, ms.Y).Direction
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
					if _G.fly_bg then
						local bg_h = max_torque_bg
						_G.fly_bg.MaxTorque = Vector3.new(bg_h, 0, bg_h)
					end
				else
					if _G.fly_bg then _G.fly_bg.MaxTorque = Vector3.new() end
				end

			elseif i.KeyCode == ANCK then
				_G.fly_rp.Parent.Anchored = not _G.fly_rp.Parent.Anchored

			elseif i.KeyCode == FSTK then
				speed = speed * (3 / 2)
				_G.fly_rp.MaxSpeed = speed

			elseif i.KeyCode == SLWK then
				speed = speed / (3 / 2)
				_G.fly_rp.MaxSpeed = speed

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
			if not _G.fly_rp or not _G.fly_rp.Parent then return end
			local do_fly = enabled and move_dir.Magnitude > 0
			if flying ~= do_fly then
				flying = do_fly
				if do_fly then
					_G.fly_rp:Fire()
				else
					_G.fly_rp:Abort()
					return
				end
			end
			_G.fly_pt.Position = _G.fly_rp.Parent.Position + 0x40 * fly_dir()
		end),
}
init()

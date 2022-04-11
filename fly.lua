local args = _G.EXEC_ARGS or {}
local key = Enum.KeyCode.H
local anck = Enum.KeyCode.G
local fstk = Enum.KeyCode.L
local slwk = Enum.KeyCode.K

local speed = args[1] or 666
local rel_to_char = args[2] or false
local max_torque_rp = args[3] or 1e4
local thrust_p = args[4] or 1e7
local max_thrust = args[5] or 5e5
local max_torque_bg = args[6] or 3e4
local thrust_d = args[7] or math.huge
local turn_p = args[8] or 1e5
local turn_d = args[9] or 2e2

local enabled = false
local lp = game.Players.LocalPlayer
local ms = lp:GetMouse()
if _G.fly_rp then _G.fly_rp:Destroy() end
if _G.fly_bg then _G.fly_bg:Destroy() end
if _G.fly_char then _G.fly_char:Disconnect() end
if _G.fly_togg then _G.fly_togg:Disconnect() end
if _G.fly_init then _G.fly_init:Disconnect() end

function init(ch)
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

_G.fly_init = lp.CharacterAdded:Connect(init)
init(lp.Character)

_G.fly_togg = game:GetService 'UserInputService'.InputBegan:Connect(
	function(i, p)
		if p then return end
		if i.KeyCode == key then
			enabled = not enabled
			if enabled then
				if _G.fly_rp then _G.fly_rp:Fire() end
				if _G.fly_bg then
					local bg_h = max_torque_bg
					_G.fly_bg.MaxTorque = Vector3.new(bg_h, 0, bg_h)
				end
			else
				if _G.fly_rp then _G.fly_rp:Abort() end
				if _G.fly_bg then _G.fly_bg.MaxTorque = Vector3.new() end
			end
		elseif i.KeyCode == anck then
			_G.fly_rp.Parent.Anchored = not _G.fly_rp.Parent.Anchored
		elseif i.KeyCode == fstk then
			speed = speed * 1.5
			_G.fly_rp.MaxSpeed = math.abs(speed)
		elseif i.KeyCode == slwk then
			speed = speed / 1.5
			_G.fly_rp.MaxSpeed = math.abs(speed)
		end
	end)

_G.fly_char = game:GetService 'RunService'.RenderStepped:Connect(
	function()
		local ch = lp.Character
		if not ch or not enabled or not _G.fly_rp.Parent then return end
		local d
		if rel_to_char then
			d = _G.fly_rp.Parent.CFrame.LookVector
		else
			d = game.workspace.CurrentCamera:ScreenPointToRay(ms.X, ms.Y).Direction
		end
		local s = 0x40 * math.sign(speed)
		_G.fly_pt.Position = _G.fly_rp.Parent.Position + d * s
	end)

local key = Enum.KeyCode.H
local anck = Enum.KeyCode.G
local fstk = Enum.KeyCode.L
local slwk = Enum.KeyCode.K
local speed = 666

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
	_G.fly_rp.MaxTorque = Vector3.new(1e4, 1e4, 1e4)
	md.PrimaryPart = _G.fly_pt
	_G.fly_pt.Anchored = true
	_G.fly_pt.CanCollide = false
	_G.fly_rp.CartoonFactor = 1
	_G.fly_rp.Target = _G.fly_pt
	_G.fly_rp.MaxSpeed = speed
	_G.fly_rp.MaxThrust = 5e5
	_G.fly_rp.ThrustP = 1e3
	_G.fly_rp.ThrustD = 1e5
	_G.fly_rp.TurnP = 1e5
	_G.fly_rp.TurnD = 2e3
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
				if _G.fly_bg then _G.fly_bg.P = 3e4 end
			else
				if _G.fly_rp then _G.fly_rp:Abort() end
				if _G.fly_bg then _G.fly_bg.P = 0 end
			end
		elseif i.KeyCode == anck then
			_G.fly_rp.Parent.Anchored = not _G.fly_rp.Parent.Anchored
		elseif i.KeyCode == fstk then
			speed = speed * 1.5
			_G.fly_rp.MaxSpeed = speed
		elseif i.KeyCode == slwk then
			speed = speed / 1.5
			_G.fly_rp.MaxSpeed = speed
		end
	end)

_G.fly_char = game:GetService 'RunService'.RenderStepped:Connect(
	function()
		local ch = lp.Character
		if not ch or not enabled or not _G.fly_rp.Parent then return end
		local r = game.Workspace.CurrentCamera:ScreenPointToRay(ms.X, ms.Y)
		_G.fly_pt.Position = _G.fly_rp.Parent.Position + r.Direction * 100
	end)

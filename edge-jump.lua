-- Full credit to NoelGamer06 at V3rmillion; imported from Infinite Yield.
local args = _E and _E.ARGS or {}
local ENABLE = args[1]
if ENABLE == nil then ENABLE = _G.ejp_evt == nil end

local lp = game.Players.LocalPlayer

local state
local laststate
local lastcf
local HST = Enum.HumanoidStateType
local function loop()
	local ch = lp.Character
	if not ch then return end
	local h = ch and ch:FindFirstChildWhichIsA 'Humanoid'
	if not h then return end

	laststate = state
	state = h:GetState()
	local hrp = h.RootPart
	if laststate ~= state and state == HST.Freefall and laststate ~= HST.Jumping then
		hrp.CFrame = lastcf
		local pow = h.JumpPower or h.JumpHeight
		local vel = hrp.AssemblyLinearVelocity
		hrp.AssemblyLinearVelocity = Vector3.new(vel.X, pow, vel.Z)
	end
	lastcf = hrp.CFrame
end

if _G.ejp_evt then
	_G.ejp_evt:Disconnect()
	_G.ejp_evt = nil
end

if ENABLE then
	_G.ejp_evt = game:GetService 'RunService'.RenderStepped:Connect(loop)
end

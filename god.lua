-- Borrowed from Infinite Yield.
local cam = game.Workspace.CurrentCamera
local lp = game.Players.LocalPlayer
local ccf = cam.CFrame
local ch = lp.Character
local h_og = ch and ch:FindFirstChildWhichIsA 'Humanoid'
local h_cl = h_og:clone()
h_cl.Parent = ch

lp.Character = nil
h_cl:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
h_cl:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
h_cl:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

h_cl.BreakJointsOnDeath = true
h_og:destroy()
h_og = nil

lp.Character = ch
cam.CameraSubject = h_cl

task.wait()
cam.CFrame = ccf

h_cl.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
local a_scpt = ch:FindFirstChild 'Animate'
if a_scpt then
	a_scpt.Disabled = true
	task.wait()
	a_scpt.Disabled = false
end
h_cl.Health = h_cl.MaxHealth

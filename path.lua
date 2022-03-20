local path = game:service 'PathfindingService':CreatePath()
if _G.path_block then return false end
local args = _G.EXEC_ARGS or {}

local pl = game.Players.LocalPlayer
local ch = pl.Character
local h = ch.Humanoid
local waypoints
local index = 1

local function compute(i)
	path:ComputeAsync(ch.PrimaryPart.Position, args[1])
	if path.Status ~= Enum.PathStatus.Success then return false end
	waypoints = path:GetWaypoints()
	index = i
	return true
end

if not compute(2) then return false end
_G.path_block = path.Blocked:Connect(compute)
_G.path_seat = h.Seated:Connect(function(a) if a then h.Jump = true end end)

local r = true
while index <= #waypoints do
	local w = waypoints[index]
	h:MoveTo(w.Position)
	h.Jump = w.Action == Enum.PathWaypointAction.Jump
	if not h.MoveToFinished:Wait() then
		r = false
		break
	end
	index = index + 1
end

_G.path_block:Disconnect()
_G.path_seat:Disconnect()
_G.path_block = nil
return r

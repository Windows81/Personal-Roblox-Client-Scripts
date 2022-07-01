--[==[HELP]==
[1] - Vector3 | CFrame | nil
	The position your character should strive to reach; default to receive input for Mouse.Hit.
]==] --
--
local path = game:service 'PathfindingService':CreatePath()
if _G.path_block then
	_G.path_block:Disconnect()
	_G.path_seat:Disconnect()
end

local args = _G.EXEC_ARGS or {}
local POSITION = args[1]

if typeof(POSITION) == 'CFrame' then
	POSITION = POSITION.Position
elseif not POSITION then
	local m = game.Players.LocalPlayer:GetMouse()
	m.Button1Up:Wait()
	POSITION = m.Hit.Position
end

local pl = game.Players.LocalPlayer
local ch = pl.Character
local h = ch.Humanoid
local waypoints
local index = 1

local function compute(i)
	path:ComputeAsync(ch.PrimaryPart.Position, POSITION)
	if path.Status ~= Enum.PathStatus.Success then return false end
	waypoints = path:GetWaypoints()
	index = i
	return true
end

if not compute(2) then
	warn('PATH WAS NOT CALCULABLE!')
	_G.EXEC_RETURN = {false}
	return
end
_G.path_block = path.Blocked:Connect(compute)
_G.path_seat = h.Seated:Connect(function(a) if a then h.Jump = true end end)
-- if h.WalkSpeed == 0 then h.WalkSpeed = 16 end

local r = true
print(#waypoints)
local b = _G.path_block
while index <= #waypoints do
	if b ~= _G.path_block then return end
	local w = waypoints[index]
	h:MoveTo(w.Position)
	print(w.Position)
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
_G.EXEC_RETURN = {r}

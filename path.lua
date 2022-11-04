--[==[HELP]==
[1] - Vector3 | CFrame | {Vector3 | CFrame} | number | nil
	If CFrame or Vector3, the position your character should strive to reach.
	If integer, receive input that many times from Mouse.Hit.
	If nil, receive pathfind destination from Mouse.Hit.
]==] --
--
if _G.path_block then _G.path_block:Disconnect() end
if _G.path_seat then _G.path_seat:Disconnect() end

local args = _E and _E.ARGS or {}
local ARGUMENT = args[1]

local pl = game.Players.LocalPlayer
local ch = pl.Character
local h = ch:FindFirstChildWhichIsA 'Humanoid'
local waypoints = {}
local index = 1

local USE_PATHFIND = false
if typeof(ARGUMENT) == 'table' then
	for i, arg in next, ARGUMENT do
		if typeof(arg) == 'CFrame' then
			arg = {Position = arg.Position, Action = Enum.PathWaypointAction.Walk}
		elseif typeof(arg) == 'Vector3' then
			arg = {Position = arg, Action = Enum.PathWaypointAction.Walk}
		end
		waypoints[i] = arg
	end

elseif typeof(ARGUMENT) == 'number' then
	local m = game.Players.LocalPlayer:GetMouse()
	for i = 1, ARGUMENT do
		m.Button1Up:Wait()
		waypoints[i] = {
			Position = m.Hit.Position,
			Action = Enum.PathWaypointAction.Walk,
		}
	end

elseif typeof(ARGUMENT) == 'CFrame' then
	ARGUMENT = ARGUMENT.Position
	USE_PATHFIND = true

elseif not ARGUMENT then
	local m = game.Players.LocalPlayer:GetMouse()
	m.Button1Up:Wait()
	ARGUMENT = m.Hit.Position
	USE_PATHFIND = true
end

if USE_PATHFIND then
	local path = game:GetService 'PathfindingService':CreatePath()
	local function compute(i)
		path:ComputeAsync(ch.PrimaryPart.Position, ARGUMENT)
		if path.Status ~= Enum.PathStatus.Success then return false end
		waypoints = path:GetWaypoints()
		index = i
		return true
	end

	if not compute(2) then
		warn('PATH WAS NOT CALCULABLE!')
		return false
		return
	end
	_G.path_block = path.Blocked:Connect(compute)
end
_G.path_seat = h.Seated:Connect(function(a) if a then h.Jump = true end end)
-- if h.WalkSpeed == 0 then h.WalkSpeed = 16 end

local r = true
local b = _G.path_block
while index <= #waypoints do
	if b ~= _G.path_block then return end
	local w = waypoints[index]
	h:MoveTo(w.Position)
	h.Jump = w.Action == Enum.PathWaypointAction.Jump
	if not h.MoveToFinished:Wait() then
		r = false
		break
	end
	index = index + 1
end

if _G.path_seat then
	_G.path_seat:Disconnect()
	_G.path_seat = nil
end

if _G.path_block then
	_G.path_block:Disconnect()
	_G.path_block = nil
end

return r

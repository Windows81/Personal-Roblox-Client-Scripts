local path = game:service 'PathfindingService':CreatePath()

function _G.path_follow(destination)
	if _G.path_block then return false end

	local pl = game.Players.LocalPlayer
	local ch = pl.Character
	local h = ch.Humanoid
	local waypoints
	local index = 1

	local function compute(i)
		path:ComputeAsync(ch.PrimaryPart.Position, destination)
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
end

_G.path_follow(Vector3.new(100))

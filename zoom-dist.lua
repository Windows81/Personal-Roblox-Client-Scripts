local pl = game.Players.LocalPlayer
local set = function(o, prop, val)
	local k = prop .. math.random(100, 999)
	if _G.zm_h[k] then _G.zm_h[k]:Disconnect() end
	o[prop] = val
	_G.zm_h[k] = o:GetPropertyChangedSignal(prop):Connect(
		function() if o[prop] ~= val then o[prop] = val end end)
end

if _G.zm_h then for _, e in next, _G.zm_h do e:Disconnect() end end
_G.zm_h = {}

set(pl, 'CameraMaxZoomDistance', 1e5)
set(pl, 'CameraMinZoomDistance', 0)
set(pl, 'CameraMode', Enum.CameraMode.Classic)
set(pl, 'DevComputerCameraMode', Enum.DevComputerCameraMovementMode.UserChoice)

local function do_char(ch)
	if not ch then return end
	local h = ch:WaitForChild('Humanoid', 7)
	if not h then return end
	set(h, 'DisplayDistanceType', Enum.HumanoidDisplayDistanceType.Subject)
	set(h, 'HealthDisplayDistance', math.huge)
	set(h, 'NameDisplayDistance', math.huge)
end

game.Players.PlayerAdded:Connect(
	function(p) p.CharacterAdded:Connect(do_char) end)
for _, p in next, game.Players:GetPlayers() do
	p.CharacterAdded:Connect(do_char)
	do_char(p.Character)
end

local pl = game.Players.LocalPlayer
local set = function(prop, val)
	if _G.zm_h[prop] then _G.zm_h[prop]:Disconnect() end
	pl[prop] = val
	_G.zm_h[prop] = pl:GetPropertyChangedSignal(prop):Connect(
		function() if pl[prop] ~= val then pl[prop] = val end end)
end

_G.zm_h = _G.zm_h or {}
set('CameraMaxZoomDistance', 1e5)
set('CameraMinZoomDistance', 0)
set('CameraMode', Enum.CameraMode.Classic)
set('DevComputerCameraMode', Enum.DevComputerCameraMovementMode.UserChoice)

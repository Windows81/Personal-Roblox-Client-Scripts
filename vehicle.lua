local args = _E and _E.ARGS or {}
local SEAT_INDEX = args[1] or 1
local SEAT_TYPE = args[2]
if SEAT_TYPE == true then
	SEAT_TYPE = 'Seat'
elseif not SEAT_TYPE then
	SEAT_TYPE = 'VehicleSeat'
end

local ch = game.Players.LocalPlayer.Character
for _, g in next, game.Workspace:GetDescendants() do
	if g:isA(SEAT_TYPE) and not g.Anchored then
		SEAT_INDEX = SEAT_INDEX - 1
		if SEAT_INDEX == 0 then
			ch:PivotTo(g.CFrame)
			g.Disabled = false
			break
		end
	end
end

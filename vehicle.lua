local args = _G.EXEC_ARGS or {}
local num = args[1] or 1
local seat_type = args[2] and 'Seat' or 'VehicleSeat'
local ch = game.Players.LocalPlayer.Character
for _, g in next, game.workspace:GetDescendants() do
	if g:isA(seat_type) and not g.Anchored then
		num = num - 1
		if num == 0 then
			ch:SetPrimaryPartCFrame(g.CFrame)
			g.Disabled = false
			break
		end
	end
end

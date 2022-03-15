local NUM = 1
local ch = game.Players.LocalPlayer.Character
for i, g in next, game.workspace:GetDescendants() do
	if g:isA 'VehicleSeat' and not g.Anchored then
		NUM = NUM - 1
		if NUM == 0 then
			ch:SetPrimaryPartCFrame(g.CFrame)
			g.Disabled = false
			break
		end
	end
end

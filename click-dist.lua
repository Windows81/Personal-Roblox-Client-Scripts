for i, g in next, game.workspace:GetDescendants() do
	if g:isA 'ClickDetector' then g.MaxActivationDistance = math.huge end
end

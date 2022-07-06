return function()
	local score = 0
	for _, p in next, game.Players:children() do
		local l = p:WaitForChild 'leaderstats'
		local dv = l:findFirstChild 'Donated'
		local rv = l:findFirstChild 'Raised'
		local d = math.max(1, dv and dv.Value or 0)
		local r = math.max(1, rv and rv.Value or 0)
		local s = 3 * math.log10(d) - math.log10(r)
		score = math.max(score, s)
	end
	return score > 14 and -1 or score
end

--[==[HELP]==
To be used with "FREE ADMIN" by Creator_Studio.
]==] --
--
local score = 0
for _, p in next, game.Players:GetPlayers() do
	local l = p:WaitForChild 'leaderstats'
	local kv = l:FindFirstChild '\u{2694} Kills'
	local dv = l:FindFirstChild '\u{2620} Deaths'
	local k = math.max(1, kv and kv.Value or 0)
	local d = math.max(1, dv and dv.Value or 0)
	local s = 3 * math.log10(k) - math.log10(d)
	score = math.max(score, s)
end
return score > 7 and false or score

--[==[HELP]==
To be used with "gas station".
]==] --
--
local t = {}
local o
for i, g in next, game.Workspace:GetDescendants() do
	if g.Name == 'three' and math.abs(g.CFrame.Z - 84.8) < .15 then
		t[#t + 1] = g
	elseif g.Name == 'five' then
		o = g
	end
end
for i, g in next, t do
	local c = o:clone()
	c.Color = g.Color
	c.CFrame = g.CFrame
	c.Parent = g.Parent
	g:destroy()
end

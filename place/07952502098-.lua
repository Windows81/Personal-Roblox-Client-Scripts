--[[
if _G.gls_evts then for _, e in next, _G.gls_evts do e:Disconnect() end end
local m = game.Workspace.GlassModel
_G.gls_evts = {}
-- _G.gls_cache = {}

function iter(pl)
	local ch = pl.Character
	if not ch then return end
	local h = ch:FindFirstChild 'Humanoid'
	if not h then return end

	local p = h.RootPart.Position
	local x = p.X - 386.554641723633
	local y = p.Y - 437.445435000000
	local z = (p.Z + 55.9119987487793) / 12
	local w = x > 0 and 2 or 1
	local i = math.round(z)
	local mod = z % 1
	if (x > 2 or x < -2) and y < 0.2 and (mod > .3 and mod < .7) then
		local n = '' .. i .. '.' .. w
		local o = m:FindFirstChild(n)
		task.wait(2)
		if not o or not o.Parent then return end
		o.Color = Color3.new(0, 0, 0)
		_G.gls_cache[i] = w
	end
end
table.insert(
	_G.gls_evts, game:GetService 'RunService'.Heartbeat:Connect(
		function() for _, pl in next, game.Players:GetPlayers() do iter(pl) end end))

for _, g in next, m:GetChildren() do
	local s = string.split(g.Name, '.')
	local i, w = tonumber(s[1]), 3 - s[2]
	local n = '' .. i .. '.' .. w;
	table.insert(
		_G.gls_evts, g.AncestryChanged:Connect(
			function()
				if not g.Parent then
					m[n].Color = Color3.new(0, 0, 0)
					_G.gls_cache[i] = w
				end
			end))
end
]] 

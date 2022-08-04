_G.pnt_l = true

local e =
	game.ReplicatedStorage.Remotes.addPaintingMarker.OnClientEvent:Connect(
		function(_, i) _G.pnt_id = i.Name end)

local fill = {
	['0'] = {
		{true, true, true},
		{true, false, true},
		{true, false, true},
		{true, false, true},
		{true, true, true},
	},
	['1'] = {
		{false, true, false},
		{false, true, false},
		{false, true, false},
		{false, true, false},
		{false, true, false},
	},
	['2'] = {
		{true, true, true},
		{false, false, true},
		{true, true, true},
		{true, false, false},
		{true, true, true},
	},
	['3'] = {
		{true, true, true},
		{false, false, true},
		{true, true, true},
		{false, false, true},
		{true, true, true},
	},
	['4'] = {
		{true, false, true},
		{true, false, true},
		{true, true, true},
		{false, false, true},
		{false, false, true},
	},
	['5'] = {
		{true, true, true},
		{true, false, false},
		{true, true, true},
		{false, false, true},
		{true, true, true},
	},
	['6'] = {
		{true, true, true},
		{true, false, false},
		{true, true, true},
		{true, false, true},
		{true, true, true},
	},
	['7'] = {
		{true, true, true},
		{false, false, true},
		{false, true, false},
		{false, true, false},
		{false, true, false},
	},
	['8'] = {
		{true, true, true},
		{true, false, true},
		{true, true, true},
		{true, false, true},
		{true, true, true},
	},
	['9'] = {
		{true, true, true},
		{true, false, true},
		{true, true, true},
		{false, false, true},
		{true, true, true},
	},
	[':'] = {{false}, {true}, {false}, {true}, {false}},
	['-'] = {{false, false}, {false, false}, {true, true}},
}
local function write(n, r, c)
	for i in tostring(n):gmatch '.' do
		local t = fill[i]
		local s = 3
		if t then
			s = #t[1] + 1
			for R, a in next, t do
				for C, b in next, a do
					if b then _G.pnt_cv[c + C - 1][r + R - 1] = Color3.new(1, 1, 1) end
				end
			end
		end
		c = c + s
	end
end
while _G.pnt_l do
	local t = tick()
	local ds = os.date('%Y-%m-%d %H:%M', t)
	if _G.pnt_ds ~= ds then

		_G.pnt_cv = {}
		_G.pnt_ds = ds
		for c = 1, 64 do
			_G.pnt_cv[c] = {}
			for r = 1, 40 do
				_G.pnt_cv[c][r] = Color3.fromHSV(
					(c / 64 + t / 3600) % 1, math.min(1, r / 20), math.min(1, 2 - r / 20))
			end
		end

		write(_G.pnt_ds, 34, 4)
		if _G.pnt_id then
			game.ReplicatedStorage.Remotes.deletePublishedPainting:FireServer(_G.pnt_id)
		end
		game.ReplicatedStorage.Remotes.savePublishedPainting:FireServer(
			'1', {
				['canvasType'] = 'Landscape',
				['canvasTable'] = _G.pnt_cv,
				['artistId'] = 1630228,
				['artist'] = 'VisualPlugin',
				['mostPrevalentColor'] = Color3.fromRGB(0, 120, 215),
				['name'] = 'Don\'t patronise me!',
				['frame'] = 'Tree',
			})
	end
	task.wait(1)
end
e:Disconnect()

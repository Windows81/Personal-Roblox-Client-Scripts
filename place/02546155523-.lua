local args = _E.ARGS
local COMMAND = args[1]:lower()

if COMMAND == 'party' then
	game.ReplicatedStorage.CS.JoinParty:FireServer(unpack(args, 2))
elseif COMMAND == 'autobring' then
	if _G.rov_br then
		_G.rov_br:Disconnect()
		_G.rov_br = nil
		return
	end
	_G.rov_br = game.Players.PlayerAdded:Connect(
		function(p)
			p.CharacterAdded:Wait()
			for i = 1, 2 do
				game.ReplicatedStorage.CS.PartyAdmin:FireServer('bring', p)
				task.wait(1)
			end
		end)
elseif COMMAND == 'parties' then
	return game.ReplicatedStorage.CS.GetPartyList:InvokeServer()
elseif COMMAND == 'rename' then
	game.ReplicatedStorage.CS.ChangeN:FireServer(unpack(args, 2))
elseif COMMAND == 'carry' then
	local plr = _E.EXEC('plr', unpack(args, 2))
	game.ReplicatedStorage.CS.CarryPlr:FireServer(plr)
elseif COMMAND == 'bring' then
	local plr = _E.EXEC('plr', unpack(args, 2))
	game.ReplicatedStorage.CS.PartyAdmin:FireServer('bring', plr)
elseif COMMAND == 'farm' then
	local area = game.Workspace.OfficeArea
	-- game.ReplicatedStorage.CS.GetJob:InvokeServer 'Office Worker'
	-- game.ReplicatedStorage.ActionEvents.Sit:FireServer(area.Model['Comfy Office Chair'].SeatModel)

	local lp = game.Players.LocalPlayer
	local ch = lp.Character
	local ccf = ch:FindFirstChildWhichIsA 'Humanoid'.RootPart.CFrame

	local EQUATION
	local ANSWERPAD
	local ASSETS = {
		['http://www.roblox.com//asset/?id=377516542'] = {00},
		['http://www.roblox.com//asset/?id=377516609'] = {01},
		['http://www.roblox.com//asset/?id=377516537'] = {02},
		['http://www.roblox.com//asset/?id=378165096'] = {03},
		['http://www.roblox.com//asset/?id=378022325'] = {04},
		['http://www.roblox.com//asset/?id=377516530'] = {05},
		['http://www.roblox.com//asset/?id=377516539'] = {06},
		['http://www.roblox.com//asset/?id=377516608'] = {07},
		['http://www.roblox.com//asset/?id=377516611'] = {08},
		['http://www.roblox.com//asset/?id=377516534'] = {09},
	}

	local function get_equation()
		for _, o in next, game.Workspace:GetDescendants() do
			if o:IsA 'SurfaceGui' then
				local a = o.Adornee or o.Parent
				if a and a:IsDescendantOf(area) then
					local d = a.CFrame:inverse() * ccf
					local e = o:FindFirstChild 'Equasion'
					if e then
						local mx = math.abs(d.X) < 1
						local my = math.abs(d.Y + 1.25) < .5
						local mz = math.abs(d.Z + 3.5) < .5
						if mx and my and mz then
							print(d, e.Text)
							return e.Text
						end
					end
				end
			end
		end
	end

	local function get_possibles()
		local result = {}
		for _, o in ANSWERPAD:GetChildren() do
			local offs = {}
			local digits = {}
			for _, p in next, o:GetChildren() do
				if p.Name == 'P' then
					local off = (p.CFrame:inverse() * o.CFrame).X
					local id = gethiddenproperty(p, 'AssetId')
					if not ASSETS[id] then p.Color = Color3.new(1, 0, 0) end
					digits[off] = ASSETS[id]
					table.insert(offs, off)
				end
			end
			table.sort(offs)
			local vals = {0}
			for _, off in next, offs do
				local new = {}
				local ds = digits[off]
				for _, d in next, ds do
					for _, v in vals do
						local n = d + 10 * v
						table.insert(new, n)
					end
				end
				vals = new
			end
			for _, v in vals do result[v] = o end
		end
		return result
	end

	for _, o in next, game.Workspace:GetDescendants() do
		if o:IsDescendantOf(area) and o.Name == 'Ans' then
			local p = o.Part
			local d = p.CFrame:inverse() * ccf
			local mx = math.abs(d.X) < 1
			local my = math.abs(d.Y + 1.25) < .5
			local mz = math.abs(d.Z + 2) < .5
			if mx and my and mz then
				ANSWERPAD = o
				break
			end
		end
	end

	if _G.rov_fl then
		_G.rov_fl = nil
		return
	end
	local tik = tick()
	_G.rov_fl = tik
	task.wait(3)
	while _G.rov_fl == tik do
		local e
		local c = 0
		repeat
			c = c + 1
			mouse1click()
			task.wait(0.2)
			e = get_equation()
			if c > 37 and e then
				print('666', e)
				-- break
			end
			if _G.rov_fl ~= tik then return end
		until e and e ~= EQUATION
		EQUATION = e
		local solution = loadstring(string.format('return %s', e))()

		local sol_o
		local c = 0
		repeat
			c = c + 1
			task.wait(0.3)
			local possible = get_possibles()
			sol_o = possible[solution]
			if c > 37 then
				-- print('555', c)
				-- break
			end
			if _G.rov_fl ~= tik then return end
		until sol_o

		-- firesignal(sol.ClickDetector.MouseClick, lp)
		local cc = game.Workspace.CurrentCamera
		local mouse_pos = cc:WorldToViewportPoint(sol_o.Position)
		mousemoveabs(mouse_pos.X, mouse_pos.Y)
		task.wait(0.5)
	end
else
	warn'Not a valid command'
end

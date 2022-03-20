--[[
A distribution of https://wearedevs.net/scripts
Created August 17, 2021, Last updated August 17, 2021

Description: Draws boxes around each player.

Credits to "Real Panda" for their ESP library

Instruction: Edit the settings as desired below and execute the script.

Settings:
Replace "nil" with "true" to enable the setting, or "false" to disable the setting. Without the quotes.
If you do not change "nil", the defaults will take place.
]] --
--
_G.ESP_Settings = {
	Enabled = true,

	ShowQuad = true,
	ShowName = true,
	ShowDistance = true,
	ShowTracer = false,

	BoxShift = CFrame.new(0, -1.5, 0),
	BoxSize = Vector3.new(4, 6, 0),
	FaceCamera = false,
	Thickness = 2,
	AllowUpdates = true,
	AttachShift = 1,
	ShowYourColour = true,
	Players = true,
	GetColour = function(box)
		local p = box.Player
		if p and p.Team then return p.Team.TeamColor.Color end
		return Color3.fromRGB(255, 170, 0)
	end,
}

function sel(a, b) return a == nil and b or a end
function hde()
	for _, o in next, _G.ESP_Objects do
		if o.Temporary then
			o:Remove()
		else
			for _, c in next, o.Components do c.Visible = false end
		end
	end
end

function rem(box)
	_G.ESP_Objects[box.Object] = nil
	for i, c in next, box.Components do
		c.Visible = false
		box.Components[i] = nil
		c:Remove()
	end
end

function draw(obj, props)
	local new = Drawing.new(obj)

	props = props or {}
	for i, v in next, props do new[i] = v end
	return new
end

function add(obj, options)
	if not obj.Parent and not options.RenderInNil then
		return warn(obj, 'has no parent')
	end

	local box = get(obj)
	if box then rem(box) end
	local name = sel(options.Name, obj.Name)
	if options.Player then
		local dn = options.Player.DisplayName
		local un = options.Player.Name
		if dn == un then
			name = un
		else
			name = string.format('%s\n[%s]', dn, un)
		end
	end

	local box = {
		AllowUpdates = sel(options.AllowUpdates, _G.ESP_Settings.AllowUpdates),
		Enabled = sel(options.Enabled, true),
		ShowDistance = options.ShowDistance,
		PrimaryPart = options.PrimaryPart,
		ShowTracer = options.ShowTracer,
		FaceCamera = options.FaceCamera,
		AutoRemove = options.AutoRemove,
		Thickness = options.Thickness,
		ShowName = options.ShowName,
		Temporary = options.Temporary,
		ShowQuad = options.ShowQuad,
		BoxShift = options.BoxShift,
		BoxSize = options.BoxSize,
		Player = options.Player,
		Colour = options.Colour,
		Object = obj,
		Name = name,
	}
	local dcol = sel(options.Colour, _G.ESP_Settings.GetColour(box))
	box.Components = {
		Quad = draw(
			'Quad', {
				Thickness = _G.ESP_Settings.Thickness,
				Color = dcol,
				Transparency = 1,
				Filled = false,
				Visible = false,
			}),
		Label = draw(
			'Text', {
				Text = '',
				Color = dcol,
				Center = true,
				Outline = true,
				Size = 19,
				Visible = false,
			}),
		Tracer = draw(
			'Line',
				{Thickness = box.Thickness, Color = dcol, Transparency = 1, Visible = false}),
	}
	_G.ESP_Objects[obj] = box

	table.insert(
		_G.ESP_Events, obj.AncestryChanged:Connect(
			function(_, parent) if not parent and box.AutoRemove then rem(box) end end))
	table.insert(
		_G.ESP_Events, obj:GetPropertyChangedSignal 'Parent':Connect(
			function() if not obj.Parent and box.AutoRemove then rem(box) end end))

	local hum = obj:FindFirstChildOfClass 'Humanoid'
	if hum then
		table.insert(
			_G.ESP_Events,
				hum.Died:Connect(function() if box.AutoRemove then rem(box) end end))
	end

	return box
end

local pl = game.Players.LocalPlayer
local cam = game.workspace.CurrentCamera
function get(obj) return _G.ESP_Objects[obj] end
function upd(obj)
	local box = get(obj)
	if not box.PrimaryPart then
		rem(box)
		return
	end

	local colour = sel(box.Colour, _G.ESP_Settings.GetColour(box))
	local upd8 = sel(box.AllowUpdates, _G.ESP_Settings.AllowUpdates)
	local hide = false
	if upd8 then
		if box.Player and not _G.ESP_Settings.ShowYourColour and
			_G.ESP_Settings.GetColour(box.Player) == _G.ESP_Settings.GetColour(pl) then
			upd8 = false
		elseif box.Disabled then
			upd8 = false
			hide = true
		elseif not workspace:IsAncestorOf(box.PrimaryPart) and
			not _G.ESP_Settings.RenderInNil then
			upd8 = false
			hide = true
		end
	end

	if hide then for _, c in next, box.Components do c.Visible = false end end
	if not upd8 then return end

	-- calculations --
	local bxsh = sel(box.BoxShift, _G.ESP_Settings.BoxShift)
	local size = sel(box.Size, _G.ESP_Settings.BoxSize)
	local shwq = sel(box.ShowQuad, _G.ESP_Settings.ShowQuad)
	local shwn = sel(box.ShowName, _G.ESP_Settings.ShowName)
	local shwd = sel(box.ShowDistance, _G.ESP_Settings.ShowDistance)
	local shwt = sel(box.ShowTracer, _G.ESP_Settings.ShowTracer)
	local atts = sel(box.AttachShift, _G.ESP_Settings.AttachShift)
	local thck = sel(box.Thickness, _G.ESP_Settings.Thickness)

	local cf = box.PrimaryPart.CFrame
	if _G.ESP_Settings.FaceCamera then
		cf = CFrame.new(cf.Position, cam.CFrame.Position)
	end
	local locs = {
		TopLeft = cf * bxsh * CFrame.new(size.X / 2, size.Y / 2, 0),
		TopRight = cf * bxsh * CFrame.new(-size.X / 2, size.Y / 2, 0),
		BottomLeft = cf * bxsh * CFrame.new(size.X / 2, -size.Y / 2, 0),
		BottomRight = cf * bxsh * CFrame.new(-size.X / 2, -size.Y / 2, 0),
		TagPos = cf * bxsh * CFrame.new(0, size.Y / 2, 0),
		Root = cf * bxsh,
	}

	if shwq then
		local tlp, tlv = cam.WorldToViewportPoint(cam, locs.TopLeft.Position)
		local trp, trv = cam.WorldToViewportPoint(cam, locs.TopRight.Position)
		local blp, blv = cam.WorldToViewportPoint(cam, locs.BottomLeft.Position)
		local brp, brv = cam.WorldToViewportPoint(cam, locs.BottomRight.Position)

		if box.Components.Quad then
			if tlv or trv or blv or brv then
				box.Components.Quad.Visible = true
				box.Components.Quad.PointA = Vector2.new(trp.X, trp.Y)
				box.Components.Quad.PointB = Vector2.new(tlp.X, tlp.Y)
				box.Components.Quad.PointC = Vector2.new(blp.X, blp.Y)
				box.Components.Quad.PointD = Vector2.new(brp.X, brp.Y)
				box.Components.Quad.Thickness = thck
				box.Components.Quad.Color = colour
			else
				box.Components.Quad.Visible = false
			end
		end
	else
		box.Components.Quad.Visible = false
	end

	if shwn or shwd then
		local tpos, tvis = cam.WorldToViewportPoint(cam, locs.TagPos.Position)

		if tvis then
			local text = table.concat(
				{
					shwn and box.Name or '',
					shwd and
						string.format('%.1f studs', (cam.CFrame.Position - cf.Position).Magnitude) or
						'',
				}, '\n')
			box.Components.Label.Visible = true
			box.Components.Label.Position = Vector2.new(
				tpos.X, tpos.Y + 7 * #text:gsub('[^\n]+', ''))
			box.Components.Label.Text = text
			box.Components.Label.Color = colour
		else
			box.Components.Label.Visible = false
		end
	else
		box.Components.Label.Visible = false
	end

	if shwt then
		local rpos, rvis = cam.WorldToViewportPoint(cam, locs.Root.Position)

		if rvis then
			box.Components.Tracer.Visible = true
			box.Components.Tracer.From = Vector2.new(rpos.X, rpos.Y)
			box.Components.Tracer.To = Vector2.new(
				cam.ViewportSize.X / 2, cam.ViewportSize.Y / atts)
			box.Components.Tracer.Thickness = thck
			box.Components.Tracer.Color = colour
		else
			box.Components.Tracer.Visible = false
		end
	else
		box.Components.Tracer.Visible = false
	end
end

function plr_add(p)
	local function chr_add(char)
		if not char:FindFirstChild 'HumanoidRootPart' then
			local ev
			ev = char.ChildAdded:Connect(
				function(c)
					if c.Name == 'HumanoidRootPart' then
						ev:Disconnect()
						add(char, {Player = p, PrimaryPart = c})
					end
				end)
			table.insert(_G.ESP_Events, ev)
		else
			add(char, {Player = p, PrimaryPart = char.HumanoidRootPart})
		end
	end
	table.insert(_G.ESP_Events, p.CharacterAdded:Connect(chr_add))
	if p.Character then spawn(function() chr_add(p.Character) end) end
end

local currEnabled = _G.ESP_Settings.Enabled
if _G.ESP_Objects then for _, o in next, _G.ESP_Objects do rem(o) end end
if _G.ESP_Events then for _, e in next, _G.ESP_Events do e:Disconnect() end end

_G.ESP_Objects = {}
_G.ESP_Events = {
	game.Players.PlayerAdded:Connect(plr_add),
	game:GetService 'RunService'.RenderStepped:Connect(
		function()
			cam = workspace.CurrentCamera
			if currEnabled ~= _G.ESP_Settings.Enabled then
				currEnabled = _G.ESP_Settings.Enabled
				if not currEnabled then hde() end
			end
			if currEnabled then
				for obj, box in next, _G.ESP_Objects do
					local s, e = pcall(upd, obj)
					if not s then warn('[EU]', e, box.PrimaryPart:GetFullName()) end
				end
			end
		end),
}
for _, p in next, game.Players:GetPlayers() do if p ~= pl then plr_add(p) end end

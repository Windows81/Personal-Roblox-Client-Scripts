game.Lighting.Bloom.Enabled = false
game.Lighting.Bloomoof.Enabled = false
game.Players.LocalPlayer.PlayerGui.DonationsGui:destroy()
for _, g in next, game.Workspace.Stage.Screens:children() do
	(g:findFirstChild 'Decal' or g:findFirstChild 'Texture'):destroy()
	local s = Instance.new 'SurfaceGui'
	local f = Instance.new 'Frame'
	f.BackgroundColor3 = Color3.new(0, 1, 0)
	f.Size = UDim2.fromScale(1, 1)
	s.Face = Enum.NormalId.Front
	f.BorderSizePixel = 0
	s.LightInfluence = 0
	f.Parent = s
	s.Parent = g
end

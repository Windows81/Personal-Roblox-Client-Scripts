local bb = game:GetService 'VirtualUser'
game.Players.LocalPlayer.Idled:Connect(
	function()
		bb:CaptureController()
		bb:ClickButton2(Vector2.new())
	end)

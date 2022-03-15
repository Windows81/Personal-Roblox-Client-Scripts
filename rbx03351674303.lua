local h, c = 0, 0
if _G.ccol then _G.ccol:disconnect() end
_G.ccol = game:GetService 'RunService'.Heartbeat:connect(
	function(d)
		c = c + d
		h = h + d
		if c > 1 / 4 then
			c = c - 1 / 4
			local C = Color3.fromHSV((h / 7) % 1, 1, 1)
			game.ReplicatedStorage.Remotes.ChangeCarStuff:FireServer(
				'Dart', 'color', '1a', C)
		end
	end)

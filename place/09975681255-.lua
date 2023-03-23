--[==[HELP]==
To be used with "Don't Know the Word" by Rejected Animators.
]==] --
--
-- #region patch chat.lua
function chat(msg, target)
	game.Players:Chat(msg)
	local rs = game:GetService 'ReplicatedStorage'
	local dcse = rs:WaitForChild 'DefaultChatSystemChatEvents'
	local smr = dcse:WaitForChild 'SayMessageRequest'
	smr:FireServer(msg, target or 'All')
end
-- #endregion patch

for _, pl in next, game.Players:GetPlayers() do
	local ch = pl.Character
	local n = pl.DisplayName
	if ch then
		local cf = ch:GetPrimaryPartCFrame()
		cf = cf * CFrame.Angles(0, math.pi, 0)
		cf = cf * CFrame.new(0, 0, 5)
		game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(cf)
		local w = ch:FindFirstChild('Word', true).Text
		if #n > 6 then n = string.format('%s…', n:sub(1, 5)) end
		local s = string.format(
			'User with display name "%s": your word is "%s".', n, w)
		chat(s)
		task.wait(2.5)
	end
end
-- rsexec syntax:
-- trans [[tree game.workspace [[l a1.Name=='Word']]]] 'm' [[f local n=a1.Parent.Parent.Parent.Humanoid.DisplayName if #n>6 then n=n:sub(1,4)..'...' end return string.format('User with display name %s: your word is "%s".',n,a1.Text)]] 'i' [[f [[chat a1]] task.wait(2.5)]]

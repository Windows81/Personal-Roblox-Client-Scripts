local MESSAGE = _E and _E.ARGS[1] or ''

-- #region patch chat.lua
function chat(msg, target)
	game.Players:Chat(msg)
	local rs = game:GetService 'ReplicatedStorage'
	local dcse = rs:WaitForChild 'DefaultChatSystemChatEvents'
	local smr = dcse:WaitForChild 'SayMessageRequest'
	smr:FireServer(msg, target or 'All')
end
-- #endregion patch
chat(MESSAGE)

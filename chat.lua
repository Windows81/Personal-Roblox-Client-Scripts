local MESSAGE = _E and _E.ARGS or _E.ARGS[1] or ''
--[[game:GetService 'ReplicatedStorage':WaitForChild 'DefaultChatSystemChatEvents'
    :WaitForChild 'SayMessageRequest':FireServer(MESSAGE, 'All')
	]]
game.Players:Chat(MESSAGE)

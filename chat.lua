local MESSAGE = _E.ARGS and _E.ARGS[1] or ''
game:GetService 'ReplicatedStorage':WaitForChild 'DefaultChatSystemChatEvents'
	:WaitForChild 'SayMessageRequest':FireServer(MESSAGE, 'All')

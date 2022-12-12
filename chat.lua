local MESSAGE = _E and _E.ARGS or  and _E.ARGS[1] or ''
game:GetService 'ReplicatedStorage':WaitForChild 'DefaultChatSystemChatEvents'
	:WaitForChild 'SayMessageRequest':FireServer(MESSAGE, 'All')

local MESSAGE = _G.EXEC_ARGS and _G.EXEC_ARGS[1] or ''
game:GetService 'ReplicatedStorage':WaitForChild 'DefaultChatSystemChatEvents'
	:WaitForChild 'SayMessageRequest':FireServer(MESSAGE, 'All')

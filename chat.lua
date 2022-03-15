local MESSAGE = ''
game:GetService('ReplicatedStorage'):WaitForChild('DefaultChatSystemChatEvents')
	:WaitForChild('SayMessageRequest'):FireServer(MESSAGE, 'All')

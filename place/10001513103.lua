-- https://codegolf.stackexchange.com/a/74685
local env = getrenv()
env.chat = function(input)
	local msg = ''
	for x in input:gmatch('%w+') do
		if msg == '' then msg = string.lower(x:sub(1, 1)) .. string.lower(x:sub(2)) end
		msg = msg .. x:sub(1, 1):upper() .. string.lower(x:sub(2))
	end
	game:GetService 'ReplicatedStorage':WaitForChild 'DefaultChatSystemChatEvents'
		:WaitForChild 'SayMessageRequest':FireServer(msg, 'All')
	return msg
end

--[==[HELP]==
To be used with "Limited Words".
]==] --
--
-- #region patch chat.lua
function chat(msg, target, skip_smr, skip_pls)
	if not skip_smr then
		local rs = game:GetService 'ReplicatedStorage'
		local dcse = rs:WaitForChild 'DefaultChatSystemChatEvents'
		local smr = dcse:WaitForChild 'SayMessageRequest'
		smr:FireServer(msg, target or 'All')
	end
	if not skip_pls then
		local pls = game:GetService 'Players'
		pls:Chat(msg)
	end
end
-- #endregion patch

-- https://codegolf.stackexchange.com/a/74685
local env = getrenv()
env.chat = function(input)
	local msg = ''
	for x in input:gmatch('%w+') do
		if msg == '' then msg = string.lower(x:sub(1, 1)) .. string.lower(x:sub(2)) end
		msg = msg .. x:sub(1, 1):upper() .. string.lower(x:sub(2))
	end
	chat(msg)
	return msg
end

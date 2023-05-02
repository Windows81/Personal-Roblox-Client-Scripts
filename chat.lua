--[==[HELP]==
[1] - string | nil
	The message to send.
	If nil, use empty string.

[2] - number | nil
	If 1, make message visible to other players but not to server events.
	If 2, make message visibie to server events but not to other players.
	If 0 or nil, make visible to both other players and server events.
]==] --
--
local args = _E and _E.ARGS or {}
local MESSAGE = args[1] or ''
local MODE = args[2] or 0

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
chat(MESSAGE, nil, MODE == 2, MODE == 1)

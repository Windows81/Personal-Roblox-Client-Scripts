--[==[HELP]==
Executes a function periodically which contains a formatted time string and the current tick().

[1] - string | nil
	Format string to be used for os.date.
	Defaults to "Happy %H:%M UTC!".

[2] - (string, number) -> ()
	Function which is called with the formatted time string.
]==] --
--
local args = _E and _E.ARGS or {}
_G.tmch_t = _G.tmch_t or {}

if #args == 1 and args[1] == false then
	for _, e in next, _G.tmch_t do e:Disconnect() end
	_G.tmch_t = nil
	return
end

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

local format = args[1] ~= nil and args[1] or [[Happy %H:%M UTC!]]
local write = args[2] or function(m, t) chat(m) end

local snap = args[3] or 5
local clear = not args[1] and true or args[4]
local index = #_G.tmch_t + 1
if clear ~= nil and typeof(clear) ~= 'boolean' then index = clear end

if clear == true then
	for _, e in next, _G.tmch_t do e:Disconnect() end
	_G.tmch_t = {}
elseif _G.tmch_t[index] then
	_G.tmch_t[index]:Disconnect()
end

local prev_ds
function loop()
	local t = math.floor(tick() / snap) * snap
	local ds = os.date(format, t)
	if prev_ds ~= ds and (not _G.time_pr or t > _G.time_pr) then
		prev_ds = ds
		write(ds, t)
		_G.time_pr = t
	end
end

if format then
	_G.tmch_t[index] = game:GetService 'RunService'.Heartbeat:Connect(loop)
end

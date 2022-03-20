local args = _G.EXEC_ARGS or {}
local format = args[1] or [[Happy %H:%M UTC!]]
local snap = args[2] or 1
local write = args[3] or function(m, t)
	game:GetService('ReplicatedStorage'):WaitForChild(
		'DefaultChatSystemChatEvents'):WaitForChild('SayMessageRequest'):FireServer(
		m, 'All')
end

if _G.time_st then _G.time_st:Disconnect() end
_G.time_st = game:GetService 'RunService'.Heartbeat:Connect(
	function()
		local t = math.floor(tick() / snap) * snap
		local ds = os.date(format, t)
		if _G.pnt_ds ~= ds then
			_G.pnt_ds = ds
			write(ds, t)
		end
	end)

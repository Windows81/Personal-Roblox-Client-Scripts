local args = _G.EXEC_ARGS or {}
local snap = args[1] or 5
local format = args[2] or [[Happy %Hh%M UTC!]]
local write = args[3] or function(m, t)
	game:GetService('ReplicatedStorage'):WaitForChild(
		'DefaultChatSystemChatEvents'):WaitForChild('SayMessageRequest'):FireServer(
		m, 'All')
end

if _G.tmch_st then _G.tmch_st:Disconnect() end
if args[1] ~= false then
	_G.tmch_st = game:GetService 'RunService'.Heartbeat:Connect(
		function()
			local t = math.floor(tick() / snap) * snap
			local ds = os.date(format, t)
			if _G.pnt_ds ~= ds and (not _G.time_pr or t > _G.time_pr) then
				_G.pnt_ds = ds
				write(ds, t)
				_G.time_pr = t
			end
		end)
end

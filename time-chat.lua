_G.time_format = [[Happy %H:%M:%S UTC!]]
_G.time_snap = 15

function write(m, t)
	game:GetService('ReplicatedStorage'):WaitForChild(
		'DefaultChatSystemChatEvents'):WaitForChild('SayMessageRequest'):FireServer(
		m, 'All')
end

if _G.time_st then _G.time_st:Disconnect() end
_G.time_st = game:GetService 'RunService'.Heartbeat:Connect(
	function()
		local t = math.floor(tick() / _G.time_snap) * _G.time_snap
		local ds = os.date(_G.time_format, t)
		if _G.pnt_ds ~= ds then
			_G.pnt_ds = ds
			write(ds, t)
		end
	end)

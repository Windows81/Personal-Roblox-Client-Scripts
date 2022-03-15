_G.time_format =
	[[<font face="Ubuntu">The time in UTC is:<br/><font size="19">%Y-%m-%d</font><br/><b><font size="23">%H:%M:%S</font></b></font>]]
_G.time_snap = 1.5

function write(m, t)
	game.ReplicatedStorage.Remotes.Request:InvokeServer(
		'SaveEdit', m, '', 'ProfilePicture', '')
end

if _G.time_st then _G.time_st:Disconnect() end
_G.time_st = game:GetService 'RunService'.Heartbeat:Connect(
	function()
		local t = math.floor(tick() / _G.time_snap + .5) * _G.time_snap
		local ds = os.date(_G.time_format, t)
		if _G.pnt_ds ~= ds then
			_G.pnt_ds = ds
			write(ds, t)
		end
	end)

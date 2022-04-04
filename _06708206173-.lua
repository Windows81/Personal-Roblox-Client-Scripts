local format = 'The time is\n%H:%M:%S UTC!'
local snap = 2
local write = function(m, t)
	game.ReplicatedStorage.CustomiseBooth:FireServer(
		'Update', {['DescriptionText'] = m, ['ImageId'] = 0})
end

if _G.time_st then _G.time_st:Disconnect() end
_G.time_st = game:GetService 'RunService'.Heartbeat:Connect(
	function()
		local t = math.floor(tick() / snap) * snap
		local ds = os.date(format, t)
		if _G.pnt_ds ~= ds and (not _G.time_pr or t > _G.time_pr) then
			_G.pnt_ds = ds
			write(ds, t)
			_G.time_pr = t
		end
	end)

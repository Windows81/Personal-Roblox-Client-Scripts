local format = 'The time is\n%H:%M:%S UTC!'
local snap = 2
local write = function(m, t)
	game.ReplicatedStorage.Booth:FireServer(
		'Update', {['Text'] = m, ['Icon'] = ''})
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

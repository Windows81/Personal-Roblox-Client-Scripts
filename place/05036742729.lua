--[==[HELP]==
To be used with "Vida Hospitalaria".
]==] --
--
local re = game.ReplicatedStorage.Knit.Services.JobService.RE
if _G.pet_e then _G.pet_e:Disconnect() end
_G.pet_e = re.OnCustomertask.spawned.OnClientEvent:Connect(
	function(w, v1, v2, m, t)
		task.wait(w)
		re.OnOrderCompleted:FireServer(true)
	end)

if _G.skin_l then
	_G.skin_l = false
	task.wait(1)
end

_G.skin_l = true
while task.wait(.3) and _G.skin_l do
	local c = Color3.fromHSV(tick() / 7 % 1, .5, 1)
	game.ReplicatedStorage.Remotes.ColorChange:FireServer(c)
end

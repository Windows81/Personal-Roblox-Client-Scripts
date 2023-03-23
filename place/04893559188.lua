--[==[HELP]==
To be used with "Edificio F3X".
]==] --
--
local id = 0
local t = math.huge
if _G.flc then _G.flc:Disconnect() end
_G.flc = game:GetService 'RunService'.Heartbeat:Connect(
	function(d)
		t = t + d
		if t < 127 then return end
		t = 0
		local r = game.ReplicatedStorage.raidRoleplay.Events.RecieveLogs:InvokeServer()
		for _, t in next, r do
			local s = t.Text:split ' | '
			_G.dlog(string.format(s[2]), false)
			if t.ID == id then break end
		end
		id = r[1].ID
	end)

--[==[HELP]==
To be used with "FREE ADMIN" by Creator_Studio.
]==] --
--
_E.EXEC('fly')
--[[
task.wait(2)
local h = {}
local pls = game.Players:GetPlayers()
for _, p in next, pls do
	if p.Character and p ~= game.Players.LocalPlayer then
		h[p] = p.Character:GetPrimaryPartCFrame()
	end
end
task.wait()
local m, pl = math.huge
for p in next, h do
	if p.Character then
		local c = p.Character:GetPrimaryPartCFrame()
		local v = (h[p].p - c.p).Magnitude
		if m > v and p.Character.Head.CFrame.UpVector.Y > .9 then
			m = v
			pl = p
		end
	end
end

local p = pl.Character.PrimaryPart.CFrame
game.ReplicatedStorage.HDAdminClient.Signals.RequestCommand:InvokeServer(
	':unff ' .. pl.Name)
game.Players.LocalPlayer.Character:PivotTo(p * CFrame.new(0, 0, 3))
mouse1click()
]]

function num(pl)
	local ch = pl.Character
	if not ch then return end
	local h = ch:FindFirstChild 'Humanoid'
	if not h or h.Health == 0 then return end
	return math.round((h.RootPart.Position.Z - 129.2021484375) / 10)
end

function cf(n)
	if not n then return end
	local b = game.Workspace.Panels.Bridge:FindFirstChild(
		n + 1 + math.floor(tick() * 8) % 2)
	if not b then return end
	return b.Correct.CFrame
end

local max = 0
for _, pl in next, game.Players:GetPlayers() do
	if pl ~= game.Players.LocalPlayer then max = math.max(max, num(pl)) end
end

local ch = game.Players.LocalPlayer.Character
local c = cf(max)
if not c then return end
ch:SetPrimaryPartCFrame(c * CFrame.new(0, 4, 0) * CFrame.Angles(0, math.pi, 0))
task.wait()

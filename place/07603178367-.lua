-- Written by VisualPlugin.
-- Execute the first time in Chipotle Burrito Builder to start counting buttiros.
-- Execute the second time to finish and save your score.
--
local args = _E and _E.ARGS or {}
local d = args[1] or 3
local t = tick()
local c = 0

if _G.cmg_t then
	_G.cmg_t = nil
	return
end
_G.cmg_t = t

game.ReplicatedStorage.RemoteEvent:FireServer('UpdateReturningPlayer')
task.wait(.5)
game.ReplicatedStorage.RemoteEvent:FireServer('startBurritoBuilder')
task.wait(.5)
game.ReplicatedStorage.RemoteFunction:InvokeServer('getBurritoBuilderData')
task.wait(.5)
game.ReplicatedStorage.RemoteEvent:FireServer('togglePlayerVisible', true)

while _G.cmg_t == t do
	task.wait(d)
	c = c + 1
	print(c)
end

_G.cmg_t = nil
game.ReplicatedStorage.RemoteEvent:FireServer('burritoBuilderResults', {c})
task.wait(.5)
game.ReplicatedStorage.RemoteEvent:FireServer('togglePlayerVisible', false)

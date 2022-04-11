local args = _G.EXEC_ARGS or {}
local d = args[1] or 3
local t = tick()
local c = 0

if _G.cmg_t then
	_G.cmg_t = nil
	return
end

_G.cmg_t = t
game.ReplicatedStorage.RemoteEvent:FireServer('UpdateReturningPlayer')
wait(.5)
game.ReplicatedStorage.RemoteEvent:FireServer('startBurritoBuilder')
wait(.5)
game.ReplicatedStorage.RemoteFunction:InvokeServer('getBurritoBuilderData')
wait(.5)
game.ReplicatedStorage.RemoteEvent:FireServer('togglePlayerVisible', true)

while _G.cmg_t == t do
	wait(d)
	c = c + 1
	print(c)
end
game.ReplicatedStorage.RemoteEvent:FireServer('burritoBuilderResults', {c})
wait(.5)
game.ReplicatedStorage.RemoteEvent:FireServer('togglePlayerVisible', false)

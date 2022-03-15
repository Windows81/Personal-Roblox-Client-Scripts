loadfile('aafk.lua')()
--loadfile('rspy.lua')()
loadfile('log.lua')()
local n = ('rbx%011d.lua'):format(game.PlaceId)
if isfile(n) then
	print('LOADFILE FOR PLACE:', pcall(loadfile('rbx' .. game.PlaceId .. '.lua')))
end

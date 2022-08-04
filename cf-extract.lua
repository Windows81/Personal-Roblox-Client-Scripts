local pl = game.Players.LocalPlayer
local F = '   ]]CFrame.new(%f,%f,%f)*CFrame.fromEulerAnglesYXZ(%f,%f,%.0f),--[['
if _G.chat then _G.chat:Disconnect() end
_G.cfs = _G.cfs or {}
_G.looping = false

function printcf()
	print('{--[[COPY FROM HERE')
	for _, cf in next, _G.cfs do
		print(string.format(F, cf.x, cf.y, cf.z, cf:toEulerAnglesYXZ()))
	end
	print('COPY UNTIL HERE]]}')
end

function slideshow_once()
	local cc = game.workspace.CurrentCamera
	cc.CameraType = 'Scriptable'
	for _, g in next, _G.cfs do
		cc.CFrame = g
		task.wait(4.56)
	end
	cc.CameraType = 'Custom'
end

function slideshow_loop()
	_G.looping = not _G.looping
	if _G.looping then
		local cc = game.workspace.CurrentCamera
		cc.CameraType = 'Scriptable'
		while _G.looping do
			for _, g in next, _G.cfs do
				cc.CFrame = g
				task.wait(4.56)
			end
		end
		cc.CameraType = 'Custom'
	end
end

_G.chat = pl.Chatted:Connect(
	function(m)
		if m == 'cfa' then
			local cf = game.workspace.CurrentCamera.CFrame
			_G.cfs[#_G.cfs + 1] = cf
		elseif m == 'cfr' then
			_G.cfs[#_G.cfs] = nil
		elseif m == 'cfp' then
			printcf()
		elseif m == 'cfs' then
			slideshow_once()
		elseif m == 'cfl' then
			slideshow_loop()
		end
	end)
print(_G.chat)

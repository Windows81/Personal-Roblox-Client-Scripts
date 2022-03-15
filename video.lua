local instances = getinstances()
if _G.vgui then
	_G.vgui:Destroy()
else
	for _, g in next, instances do
		if g:isA 'Sound' then g.Volume = g.Volume / 256 end
	end
end
local l = game:GetService 'ContentProvider':ListEncryptedAssets()
_G.vgui = Instance.new('ScreenGui', game:GetService 'CoreGui')
_G.vgui.IgnoreGuiInset = not _G.vgui.IgnoreGuiInset
_G.vgui.DisplayOrder = 1337
local vf = Instance.new('VideoFrame', _G.vgui)
vf.Size = UDim2.fromScale(1, 1)

local g = _G.vgui
for _, v in next, l do
	vf.Video = v
	vf:Play()
	vf.Ended:Wait()
	if g ~= _G.vgui then return end
end

_G.vgui:Destroy()
_G.vgui = nil

for _, g in next, instances do
	if g:isA 'Sound' then g.Volume = g.Volume * 256 end
end

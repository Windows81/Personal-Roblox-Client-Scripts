local args = _E and _E.ARGS or {}
local instances = getinstances()
local index = args[1] or 1
if _G.vgui then
	_G.vgui:Destroy()
else
	for _, g in next, instances do
		if g:isA 'Sound' then g.Volume = g.Volume / 256 end
	end
end
local l = game:GetService 'ContentProvider':ListEncryptedAssets()
game:GetService 'ContentProvider':PreloadAsync(l, print)
_G.vgui = Instance.new('ScreenGui', game:GetService 'CoreGui')
_G.vgui.IgnoreGuiInset = not _G.vgui.IgnoreGuiInset
_G.vgui.DisplayOrder = 1337
local vf = Instance.new('VideoFrame', _G.vgui)
vf.Size = UDim2.fromScale(1, 1)
vf.BackgroundTransparency = .5

local g = _G.vgui
local v = l[index]
print(v)
vf.Video = v
vf:Play()
vf.Ended:Wait()

if g == _G.vgui then _G.vgui = nil end
g:Destroy()

for _, g in next, instances do
	if g:isA 'Sound' then g.Volume = g.Volume * 256 end
end

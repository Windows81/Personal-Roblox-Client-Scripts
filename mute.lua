local function f(o) return o:isA 'Sound' and o.Parent.Name ~= 'HumanoidRootPart' end
if _G.mute then
	rsexec('force-obj-prop', 'Volume', f, false)
else
	rsexec('force-obj-prop', 'Volume')
end
_G.mute = not _G.mute

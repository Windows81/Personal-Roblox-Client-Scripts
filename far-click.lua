--[==[HELP]==
This script essentially increases the maximum activation distance of all ClickDetector objects to a huge number.
]==] --
--
local function extend(o)
	if o:isA 'ClickDetector' then
		o.MaxActivationDistance = o.MaxActivationDistance * 0x10000
		_G.cdec_cache[o] = true
	end
end

local function restore(o)
	if _G.cdec_cache[o] then
		o.MaxActivationDistance = o.MaxActivationDistance / 0x10000
		_G.cdec_cache[o] = nil
	end
end

if _G.cdec_cache then
	for _, g in next, _G.cdec_cache do restore(g) end
	_G.cdec_evt:Disconnect()
else
	_G.cdec_cache = {}
	for _, g in next, game.Workspace:GetDescendants() do extend(g) end
	_G.cdec_evt = game.Workspace.DescendantAdded:Connect(extend)
end

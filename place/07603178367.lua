local args = _E and _E.ARGS or {}
local d = args[1] or 3
local t = tick()
local c = 0

if _G.cmg_t then
	_G.cmg_t = nil
	return
end

for _, g in next, game:GetDescendants() do
	if g:isA 'GuiBase2d' then g.AutoLocalize = false end
end

-- _E.EXEC'PLACE'

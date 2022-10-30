--[==[HELP]==
Taken from the Infinite Yield command 'norender'.
Disables 3D Rendering to decrease CPU load.

[1] - bool | nil
	If true, disables 3D rendering.
	If false, re-enables 3D rendering.
	If nil, acts as a toggle.
]==] --
--
local args = _E and _E.ARGS or {}
local SET_DISABLED = args[1]
if SET_DISABLED == nil then SET_DISABLED = not _G.rndr_dis end

local rs = game:GetService 'RunService'
rs:Set3dRenderingEnabled(not SET_DISABLED)
_G.rndr_dis = SET_DISABLED

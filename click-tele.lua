--[==[HELP]==
[1] - {BasePart | Model | Vector3 | CFrame} | BasePart | Model
	The domain of objects to which you can teleport.

[2] - number | nil
	The number of seconds to task.wait before teleporting to the next object; defaults to task.wait until next click.
]==] --
--
local ts = tick()
_G.tpo_ts = ts
local args = _E and _E.ARGS or {}
local pl = game.Players.LocalPlayer
local range = args[1] or game.Players.Workspace:GetDescendants()
if typeof(range) == 'Instance' then range = {range} end
local m = pl:GetMouse()
local l = #range

local function await()
	if args[2] then
		task.wait(args[2])
	else
		m.Button1Up:Wait()
	end
end

for i, v in next, range do
	if _G.tpo_ts ~= ts then break end
	local cf
	local typ = typeof(v)
	if typ == 'Instance' then
		if v:isA 'BasePart' then
			cf = v.CFrame
		elseif v:isA 'Model' then
			cf = v:GetPivot()
		end
	elseif typ == 'Vector3' then
		cf = CFrame.new(v)
	elseif typ == 'CFrame' then
		cf = v
	end

	if cf then
		await()
		pl.Character:PivotTo(cf)
		print(string.format('Teleported to object %03d out of %03d', i, l))
	else
		warn(string.format('Teleport obj skipped %03d out of %03d', i, l))
	end
end

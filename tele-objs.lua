--[==[HELP]==
[1] - {BasePart | Model}
	The domain of objects to which you can teleport.

[2] - number | nil
	The number of seconds to wait before teleporting to the next object; defaults to wait until next click.
]==] --
--
local t = tick()
_G.tpo_ts = t
local args = _G.EXEC_ARGS or {}
local pl = game.Players.LocalPlayer
local range = args[1] or game.Players.Workspace:GetDescendants()
local m = pl:GetMouse()
local l = #range

local function w()
	if args[2] then
		wait(args[2])
	else
		m.Button1Up:Wait()
	end
end

w()
for i, v in next, range do
	if _G.tpo_ts ~= t then break end
	local cf
	local t = typeof(v)
	if t == 'Instance' then
		if v:isA 'BasePart' then
			cf = v.CFrame
		elseif v:isA 'Model' then
			cf = v:GetPivot()
		end
	elseif t == 'Vector3' then
		cf = CFrame.new(v)
	elseif t == 'CFrame' then
		cf = v
	end

	local ch = pl.Character
	if ch and cf then
		ch:SetPrimaryPartCFrame(cf)
		print(string.format('Teleported to object %03d out of %03d', i, l))
		w()
	else
		warn(string.format('Teleport obj skipped %03d out of %03d', i, l))
	end
end

local args = _G.EXEC_ARGS or {}
local pl = game.Players.LocalPlayer
local range = args[1] or game.Players.Workspace:GetDescendants()
local m = pl:GetMouse()
local l = #range

for i, v in next, range do
	local _ = args[2] and wait(args[2]) or m.Button1Up:Wait()
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
	if ch then ch:SetPrimaryPartCFrame(cf) end
	print(string.format('Teleported to obj. %03d out of %03d', i, l))
end

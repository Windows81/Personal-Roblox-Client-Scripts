local args = _E and _E.ARGS or {}
local pl = game.Players.LocalPlayer
local to_name = args[1]
local wait_d = args[2]

local m = pl:GetMouse()
if wait_d then
	task.wait(wait_d)
else
	m.Button1Up:Wait()
	task.wait(2)
end

local to_pl
local min = math.huge
for _, p in next, game.Players:children() do
	if p ~= pl then
		local nv = math.huge
		local un = p.Name
		local dn = p.DisplayName

		if un:find('^' .. to_name) then
			nv = 1.0 * (#un - #to_name)

		elseif dn:find('^' .. to_name) then
			nv = 1.5 * (#dn - #to_name)

		elseif un:lower():find('^' .. to_name:lower()) then
			nv = 2.0 * (#un - #to_name)

		elseif dn:lower():find('^' .. to_name:lower()) then
			nv = 2.5 * (#dn - #to_name)

		end
		if nv < min then
			to_pl = p
			min = nv
		end
	end
end

local n = to_pl.Name
local rc = game.ReplicatedStorage.HDAdminClient.Signals.RequestCommand
rc:InvokeServer(string.format(':ungod %s', n))
rc:InvokeServer(string.format(':health %s 1', n))
rc:InvokeServer(string.format(':freeze %s', n))
rc:InvokeServer(string.format(':unff %s', n))
rc:InvokeServer(':god me')

local cf = pl.Character:GetPrimaryPartCFrame()
pl.Character:SetPrimaryPartCFrame(
	to_pl.Character:GetPrimaryPartCFrame() * CFrame.new(0, 2, 3.5))
mouse1click()
task.wait(2)
pl.Character:SetPrimaryPartCFrame(cf)

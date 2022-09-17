local args = _G.EXEC_ARGS or {}
local pl = game.Players.LocalPlayer
local to_name = args[1]

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

if not to_pl or not to_pl.Character then return end
local hrp = to_pl.Character:findFirstChild 'HumanoidRootPart'
local trs = to_pl.Character:findFirstChild 'Torso'
local to_part = hrp or trs

pl.Character:SetPrimaryPartCFrame(to_part.CFrame)
print(string.format('TELEPORT TO %s', to_pl.Name))

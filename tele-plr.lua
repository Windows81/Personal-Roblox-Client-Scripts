--[==[HELP]==
Teleports to a specified player.

[1] - Player | string
	If string is passed in: prefix of the desired player's username (weight == 1.0) or display name (weight == 1.5).
]==] --
--
local args = _E and _E.ARGS or {}
local pl = game.Players.LocalPlayer
local PLAYER_REF = args[1]

local to_pl
if typeof(PLAYER_REF) == 'string' then
	local min = math.huge
	for _, p in next, game.Players:GetPlayers() do
		if p ~= pl then
			local nv = math.huge
			local un = p.Name
			local dn = p.DisplayName

			if un:find('^' .. PLAYER_REF) then
				nv = 1.0 * (#un - #PLAYER_REF)

			elseif dn:find('^' .. PLAYER_REF) then
				nv = 1.5 * (#dn - #PLAYER_REF)

			elseif un:lower():find('^' .. PLAYER_REF:lower()) then
				nv = 2.0 * (#un - #PLAYER_REF)

			elseif dn:lower():find('^' .. PLAYER_REF:lower()) then
				nv = 2.5 * (#dn - #PLAYER_REF)

			end
			if nv < min then
				to_pl = p
				min = nv
			end
		end
	end
else
	to_pl = PLAYER_REF
end

if not to_pl or not to_pl.Character then return end
local hrp = to_pl.Character:FindFirstChild 'HumanoidRootPart'
local trs = to_pl.Character:FindFirstChild 'Torso'
local to_part = hrp or trs

pl.Character:SetPrimaryPartCFrame(to_part.CFrame)
print(string.format('TELEPORT TO %s', to_pl.Name))

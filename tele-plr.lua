--[==[HELP]==
Teleports to a specified player.

[1] - Player | string
	If string is passed in: prefix of the desired player's username (weight == 1.0) or display name (weight == 1.5).
]==] --
--
local args = _E and _E.ARGS or {}
local pl = game.Players.LocalPlayer
local PLAYER_REF = args[1]

-- #region patch infer-plr.lua
function infer_plr(pl_ref)
	local to_pl
	local lp = game.Players.LocalPlayer
	if typeof(pl_ref) == 'string' then
		local min = math.huge
		for _, p in next, game.Players:GetPlayers() do
			if p ~= lp then
				local nv = math.huge
				local un = p.Name
				local dn = p.DisplayName

				if un:find('^' .. pl_ref) then
					nv = 1.0 * (#un - #pl_ref)

				elseif dn:find('^' .. pl_ref) then
					nv = 1.5 * (#dn - #pl_ref)

				elseif un:lower():find('^' .. pl_ref:lower()) then
					nv = 2.0 * (#un - #pl_ref)

				elseif dn:lower():find('^' .. pl_ref:lower()) then
					nv = 2.5 * (#dn - #pl_ref)

				end
				if nv < min then
					to_pl = p
					min = nv
				end
			end
		end
		return to_pl
	else
		return pl_ref
	end
end
-- #endregion patch

local to_pl = infer_plr(PLAYER_REF)
if not to_pl or not to_pl.Character then return end
local hrp = to_pl.Character:FindFirstChild 'HumanoidRootPart'
local trs = to_pl.Character:FindFirstChild 'Torso'
local to_part = hrp or trs

pl.Character:SetPrimaryPartCFrame(to_part.CFrame)
print(string.format('TELEPORT TO %s', to_pl.Name))

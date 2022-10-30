--[==[HELP]==
Returns a player object given the prefix.

[1] - string
	Prefix of that player's username (weight == 1.0) or display name (weight == 1.5).
]==] --
--
local args = _E.ARGS
local pl = game.Players.LocalPlayer
local PLAYER_REF = args[1]

local to_pl
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

_E.RETURN = {to_pl}

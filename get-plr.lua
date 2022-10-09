local args = _G.EXEC_ARGS
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

_G.EXEC_RETURN = {to_pl}

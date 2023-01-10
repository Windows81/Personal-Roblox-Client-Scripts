--[==[HELP]==
Credit to @shayrbx (https://github.com/EdgeIY/infiniteyield/pull/101) for current implementation.
Prevents local scripts from calling Player:Kick().
]==] --
--
local valid_names = {'Kick', 'kick'}
local lp = game.Players.LocalPlayer

-- Prevents sanity-checking "Player.KiCk()", etc. which don't point to an actual function.
for _, f in ipairs(valid_names) do
	local old_func
	old_func = hookfunction(
		lp[f], newcclosure(
			function(self, ...)
				if self == lp then return end
				return old_func(...)
			end))
end

local old_nmcl
old_nmcl = hookmetamethod(
	game, '__namecall', function(self, ...)
		if self == lp and table.find(valid_names, getnamecallmethod()) then return end
		return old_nmcl(self, ...)
	end)

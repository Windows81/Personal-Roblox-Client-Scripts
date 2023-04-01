--[==[HELP]==
Overrides the local player's for future calls to GetCountryRegionForPlayerAsync.

[1] - string | nil
	The two-letter ISO country code which shall be returned.
	Defaults to 'GB'.
]==] --
--
local args = _E and _E.ARGS or {}
local CHOSEN_REGION = args[1] or 'GB'

local ls = game:GetService 'LocalizationService'
local lp = game.Players.LocalPlayer

local hook_m
hook_m = hookmetamethod(
	ls, '__namecall', newcclosure(
		function(self, ...)
			local m_name = getnamecallmethod()
			if self ~= ls or m_name ~= 'GetCountryRegionForPlayerAsync' then --
				return hook_m(self, ...)
			end

			local m_args = {...}
			local plr = m_args[1]

			if plr ~= lp then --
				return hook_m(self, ...)
			end

			return CHOSEN_REGION
		end))

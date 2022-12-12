--[==[HELP]==
Changes display language for current Roblox session.

[1] - string | nil
	Experience settings locale string; defaults to "en-us".

[2] - string | nil
	Roblox client locale string; defaults to provided experience locale or "en-us".
]==] --
--
local args = _E and _E.ARGS or {}
local EXP_L = args[1] or 'en-us'
local RBX_L = args[2] or args[1] or 'en-us'
game.Players.LocalPlayer:SetExperienceSettingsLocaleId(EXP_L)
game.LocalizationService:SetRobloxLocaleId(RBX_L)

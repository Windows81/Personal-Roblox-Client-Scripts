--[==[HELP]==
Taken from Infinite Yield's 'clientantikick' command.
Prevents local scripts from calling Player:Kick().
]==] --
--
local lp = game.Workspace.Players.LocalPlayer
local old_index, old_namecall

old_index = hookmetamethod(
	game, '__index', function(self, method)
		if self == lp and method == 'Kick' then
			return error('Expected \':\' not \'.\' calling member function Kick', 2)
		end
		return old_index(self, method)
	end)

old_namecall = hookmetamethod(
	game, '__namecall', function(self, ...)
		if self == lp and getnamecallmethod() == 'Kick' then return end
		return old_namecall(self, ...)
	end)

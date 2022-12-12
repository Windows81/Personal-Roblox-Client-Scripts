--[==[HELP]==
Taken from Infinite Yield's 'clientantikick' command.
Prevents local scripts from calling Player:Kick().
]==] --
--
local lp = game.Players.LocalPlayer
local old_index, old_namecall

local function check(self, m) return self == lp and m:lower() == 'kick' end
local function dummy(...) _E.EXEC('output', 'Tried to kick:', ...) end

old_index = hookmetamethod(
	game, '__index', function(self, method, ...)
		if check(self, method) then
			error('Expected \':\' not \'.\' calling member function Kick', 2)
			return dummy(...)
		end
		return old_index(self, method)
	end)

old_namecall = hookmetamethod(
	game, '__namecall', function(self, ...)
		if check(self, getnamecallmethod()) then --
			return dummy(...)
		end
		return old_namecall(self, ...)
	end)

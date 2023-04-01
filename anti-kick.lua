-- Taken from https://github.com/CF-Trail/random/blob/e8b62391001a9e3ae5e17524cc52f85330e99470/utilLoader/init.lua.
local is_adonis = false
local lp = game.Players.LocalPlayer
local rs = game:GetService 'ReplicatedStorage'

local function check_adonis(o)
	if not o:isA 'RemoteEvent' then return false end
	local f = o:FindFirstChildWhichIsA 'RemoteFunction'
	if f.Name ~= '__FUNCTION' then return false end
	is_adonis = true
	return true
end

repeat task.wait() until game:IsLoaded()
for _, o in next, rs:GetDescendants() do check_adonis(o) end

if not is_adonis then
	_G.adonis_checker = rs.ChildAdded:Connect(
		function(o)
			task.wait()
			if not check_adonis(o) then return end
			_G.adonis_checker:Disconnect()
			_G.adonis_checker = nil
		end)
end

task.spawn(
	function()
		hookfunction(
			lp.Destroy, newcclosure(
				function(...)
					local args = {...}
					if checkcaller() then return end
					return task.wait(9e9)
				end))
		if not is_adonis then
			hookfunction(
				lp.Kick, newcclosure(
					function(...)
						local args = {...}
						if checkcaller() or is_adonis then return end
						return task.wait(9e9)
					end))
		end
	end)

local old_nc
old_nc = hookmetamethod(
	game, '__namecall', newcclosure(
		function(self, ...)
			local kscriptz, kscript
			local method = string.lower(getnamecallmethod())
			if self ~= lp or checkcaller() then return end

			if method == 'kick' then
				kscriptz = getcallingscript()
				if kscriptz then
					kscript = kscriptz:GetFullName()
				else
					kscript = 'Couldn\'t fetch'
				end
				print(string.format('Blocked kick from "%s"', tostring(kscript)))
				return task.wait(9e9)

			elseif method == 'destroy' then
				kscriptz = getcallingscript()
				if kscriptz then
					kscript = kscriptz:GetFullName()
				else
					kscript = 'Couldn\'t fetch'
				end
				print(string.format('Blocked kick from "%s"', tostring(kscript)))
				return task.wait(9e9)
			end

			return old_nc(self, ...)
		end))

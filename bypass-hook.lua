local BYPASS_TABLE = {
	['discord'] = 'disco{{aieixzvzx:rd}}',
	['discord.com'] = 'disco{{aieixzvzx:rd.com}}',
}

local rs = game:GetService 'ReplicatedStorage'
local dcse = rs:WaitForChild 'DefaultChatSystemChatEvents'
local smr = dcse:WaitForChild 'SayMessageRequest'

local hook_m
hook_m = hookmetamethod(
	smr, '__namecall', function(self, ...)
		local m_name = getnamecallmethod()
		local m_args = {...}

		if self ~= smr or m_name ~= 'FireServer' then --
			return hook_m(self, ...)
		end

		local msg = m_args[1]
		return string.gsub(
			msg, '%S+', function(sec)
				local low = sec:lower()
				local upp = sec:upper()
				local bypass = BYPASS_TABLE[low]
				if not bypass then return sec end

				local bypass_upp = bypass:upper()
				if upp == sec then return bypass_upp end
				local sec_f = sec:sub(1, 1)
				local upp_f = upp:sub(1, 1)
				if upp_f == sec_f then
					return bypass_upp:sub(1, 1) .. bypass:sub(2)
				else
					return bypass
				end
			end)
	end)

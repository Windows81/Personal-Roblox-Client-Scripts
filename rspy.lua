--[[
	Lua U Remote Spy written by chaserks, refactored by VisualPlugin.
	Execution environments supported: Synapse X, ProtoSmasher, WeAreDevs (Sirhurt?, Elysian?).
	Remote calls are printed to the dev console by default (F9 window).
	To use Synapse's console, change Settings.Output to rconsoleprint.
]] --
local args = _E and _E.ARGS or {}
local function arg_sel(n, d)
	local v = type(args[1]) == 'table' and args[1][n] or args[n]
	return v == nil and d or v
end

local output_f = arg_sel(3)
if not output_f then
	local path = '_rspy.dat'
	output_f = function(l) appendfile(path, l) end
	writefile(path, '')
end

local SETTINGS = {
	ToServerEnabled = arg_sel(1, true), -- Events to the server are logged.
	ToClientEnabled = arg_sel(2, true), -- Events to the client are logged.
	Blacklist = arg_sel(
		8, { -- Ignore remote calls made with these remotes.
			['.DefaultChatSystemChatEvents.OnMessageDoneFiltering'] = true,
			['.DefaultChatSystemChatEvents.OnNewSystemMessage'] = true,
			['.DefaultChatSystemChatEvents.SayMessageRequest'] = true,
			['.DefaultChatSystemChatEvents.OnNewMessage'] = true,
			['.ReplicatedStorage.PerspectiveLookEvent'] = true,
			['.ReplicatedStorage.raidRoleplay.Events.RecieveLogs'] = true, -- 4893559188
			['.ReplicatedStorage.ClientBridge.MouseCursor'] = true, -- 6982988368
			['.ReplicatedStorage.WeaponCommunication.CameraUpdated'] = true, -- 6594449288
			['.ReplicatedStorage.updstatus'] = true, -- 4628761410
			['.ReplicatedStorage.BuildingEvents.CheckOtherPlayerPlatinum'] = true, -- 02546155523
			['.ReplicatedStorage.CS.GetInstaVilleFeed'] = true, -- 02546155523
			['.ReplicatedStorage.CS.StreamArea'] = true, -- 02546155523
			['.ReplicatedStorage.BuildingEvents.GetPropertyValue'] = true, -- 02546155523
			['.ReplicatedStorage.CS.GiveFoodDiner'] = true, -- 02546155523
			['.ReplicatedStorage.VisualRemotes.ChangeNeckWeld'] = true, -- 9664467600
			['.ReplicatedStorage.GameRemotes.GetBiome'] = true, -- 9664467600
			['.ReplicatedStorage.Phone.GetMissionsData'] = true, -- 735030788
			['.ReplicatedStorage.SocialInteractions.UpdateBodyOrientation'] = true, -- 9194124128
		}),
	LineBreak = arg_sel(9, '\n'),
	BlockBreak = arg_sel(10, '\n\n'),
	ShowScript = arg_sel(6, true), -- Print out the script that made the remote call (nonfunctional with ProtoSmasher).
	ShowReturns = arg_sel(7, true), -- Display what the remote calls return.
	Output = output_f, -- Function used to output remote calls (rconsoleprint uses Synapse's console).
	ProtectFunction = arg_sel(4, false), -- Set to false in case RSpy crashes for you with certain server events.
}

if _G.RSpy_Settings then return end
_G.RSpy_Settings = SETTINGS

local metatable = getrawmetatable(game)
local _, make_writeable = next{ --
	make_writeable,
	setreadonly,
	set_readonly,
}

local _, detour_function = next{ --
	detour_function,
	replace_closure,
	hookfunction,
}

local _, get_namecall_method = next{ --
	get_namecall_method,
	getnamecallmethod,
	function(o) return typeof(o) == 'Instance' and Methods[o.ClassName] or nil end,
}

local _, protect_function = next{ --
	SETTINGS.ProtectFunction and protect_function or nil,
	SETTINGS.ProtectFunction and newcclosure or nil,
	function(...) return ... end,
}

local _, get_instances = next{ --
	getinstances,
	function() return game:GetDescendants() end,
}

_G.RSpy_Original = {}
local methods = {RemoteEvent = 'FireServer', RemoteFunction = 'InvokeServer'}

local function obj_name(Object) -- Returns proper string wrapping for instances
	local Name = Object.Name
	return
		((#Name == 0 or Name:match('[^%w]+') or Name:sub(1, 1):match('[^%a]')) and
			'["%s"]' or '.%s'):format(Name)
end

local function in_blacklist(Object)
	local path = obj_name(Object)
	if SETTINGS.Blacklist[path:sub(2)] then return true end
	local parent = metatable.__index(Object, 'Parent')
	while parent and parent ~= game do
		path = obj_name(parent) .. path
		if SETTINGS.Blacklist[path] then return true end
		parent = metatable.__index(parent, 'Parent')
	end
	return false
end

-- Convert the types into strings.
local function parse(obj)
	local t = typeof(obj)
	if t == 'string' then
		return ('"%s"'):format(obj)

		-- Instance:GetFullName(), except it's not handicapped.
	elseif t == 'Instance' then
		local Path = obj_name(obj)
		local Parent = metatable.__index(obj, 'Parent')
		while Parent and Parent ~= game do
			Path = obj_name(Parent) .. Path
			Parent = metatable.__index(Parent, 'Parent')
		end
		return (obj:IsDescendantOf(game) and 'game' or 'NIL') .. Path

	elseif t == 'table' then
		local Str = ''
		local Counter = 0
		for Idx, Obj in next, obj do
			Counter = Counter + 1
			local Obj = Obj ~= obj and parse(Obj) or 'THIS_TABLE'
			if Counter ~= Idx then
				local IdxStr = Idx ~= obj and parse(Idx) or 'THIS_TABLE'
				Str = Str .. ('[%s] = %s, '):format(IdxStr, Obj) -- maybe
			else
				Str = Str .. ('%s, '):format(Obj)
			end
		end
		return ('{%s}'):format(Str:sub(1, -3))

	elseif t == 'CFrame' or t == 'Vector3' or t == 'Vector2' or t == 'UDim2' or t ==
		'Vector3int16' then
		return ('%s.new(%s)'):format(t, tostring(obj))

	elseif t == 'Color3' then
		return ('%s.fromRGB(%d, %d, %d)'):format(
			t, obj.R * 255, obj.G * 255, obj.B * 255)

	elseif t == 'userdata' then -- Remove __tostring fields to counter traps
		local res
		local meta = getrawmetatable(obj)
		local __tostring = meta and meta.__tostring
		if __tostring then
			make_writeable(meta, false)
			meta.__tostring = nil
			res = tostring(obj)
			rawset(meta, '__tostring', __tostring)
			make_writeable(meta, rawget(meta, '__metatable') ~= nil)
		else
			res = tostring(obj)
		end
		return res
	else
		return tostring(obj)
	end
end

local function write(remote, format, arguments, script, returns)
	local line = format:format(parse(remote), parse(arguments):sub(2, -2))
	SETTINGS.Output(line)

	if SETTINGS.ShowScript and script then
		if typeof(script) == 'Instance' then
			SETTINGS.Output(('%sScript: %s'):format(SETTINGS.LineBreak, parse(script)))
		end
	end
	if SETTINGS.ShowReturns and returns and #returns > 0 then
		SETTINGS.Output(
			('%sReturned: %s'):format(
				SETTINGS.LineBreak, parse(returns):sub(2, -2)))
	end
	SETTINGS.Output(SETTINGS.BlockBreak)
end

local function hook_server(self, method_n, f, ...)
	if not SETTINGS.ToServerEnabled then
		return f(self, ...)
	elseif typeof(self) ~= 'Instance' then
		return f(self, ...)
	elseif typeof(method_n) ~= 'string' then
		return f(self, ...)
	elseif methods[self.ClassName] ~= method_n then
		return f(self, ...)
	elseif in_blacklist(self) then
		return f(self, ...)
	end

	-- ProtoSmasher HATES getfenv(4); detour_function breaks!
	local env_s, env = pcall(getfenv, 4)
	local show_s = SETTINGS.ShowScript and not PROTOSMASHER_LOADED
	local env_sc = show_s and rawget(env, 'script') or nil

	local arguments = {...}
	local format = string.format('%%s:%s(%%s)', method_n)
	if not SETTINGS.ShowReturns then
		write(self, format, arguments, env_sc)
		return f(self, ...)
	end

	local returns = {f(self, ...)}
	if env_s then write(self, format, arguments, env_sc, returns) end
	return unpack(returns)
end

-- Anti-detection for tostring; tostring(FireServer, InvokeServer)
do
	local CURR = tostring
	local ORIG = _G.RSpy_Original[CURR] or CURR
	local NEWF = protect_function(
		function(obj)
			local s, res = pcall(CURR or original_function, _G.RSpy_Original[obj] or obj)
			if s then
				return res
			else
				error(res:gsub(script.Name .. ':%d+: ', ''))
			end
		end)
	_G.RSpy_Original[CURR] = nil
	_G.RSpy_Original[NEWF] = ORIG
	CURR = detour_function(CURR, NEWF)
end

-- FireServer and InvokeServer hooking; FireServer(Remote, ...)
for class, method in next, methods do
	local CURR = Instance.new(class)[method]
	local ORIG = _G.RSpy_Original[CURR] or CURR
	local NEWF = protect_function(
		function(self, ...)
			local f = CURR or original_function
			return hook_server(self, method, f, ...)
		end)
	_G.RSpy_Original[CURR] = nil
	_G.RSpy_Original[NEWF] = ORIG
	CURR = detour_function(CURR, NEWF)
end

-- Namecall hooking; Remote:FireServer(...)
do
	local CURR = metatable.__namecall
	local ORIG = _G.RSpy_Original[CURR] or CURR
	local NEWF = protect_function(
		function(self, ...)
			local mn = get_namecall_method(self)
			local f = CURR or original_function
			return hook_server(self, mn, f, ...)
		end)
	_G.RSpy_Original[CURR] = nil
	_G.RSpy_Original[NEWF] = ORIG
	--[[
	CURR = hookmetamethod(game, '__namecall', NEWF)
	]]
	make_writeable(metatable, false)
	metatable.__namecall = NEWF
	make_writeable(metatable, true)
end

-- Connect to remotes; Remote:FireClient(...)
do
	local function hook_evt(remote)
		if remote.ClassName == 'RemoteEvent' then
			remote.OnClientEvent:Connect(
				function(...)
					if SETTINGS.ToClientEnabled and not in_blacklist(remote) then
						local Format = '%s.OnClientEvent » (%s)'
						write(remote, Format, {...}, nil, nil)
					end
				end)
		end
	end
	game.DescendantAdded:Connect(hook_evt)
	for _, o in next, get_instances() do hook_evt(o) end
end

warn('Settings:')
table.foreach(SETTINGS, print)
warn('----------------')

--[[
	Lua U Remote Spy written by chaserks, refactored by VisualPlugin.
	Exploits supported: Synapse X, ProtoSmasher, JJSploit (Sirhurt?, Elysian?).
	Remote calls are printed to the dev console by default (F9 window).
	To use Synapse's console, change Settings.Output to rconsoleprint.
]] --
local args = _G.EXEC_ARGS or {}
local function sel(n, d)
	local v = type(args[1]) == 'table' and args[1][n] or args[n]
	return v == nil and d or v
end

_G.RSpy_Settings = {
	ToClientEnabled = sel(2, false), -- Events to the client are logged.
	ToServerEnabled = sel(1, true), -- Events to the server are logged.
	Blacklist = sel(
		7, { -- Ignore remote calls made with these remotes.
			['.DefaultChatSystemChatEvents.OnMessageDoneFiltering'] = true,
			['.DefaultChatSystemChatEvents.OnNewSystemMessage'] = true,
			['.DefaultChatSystemChatEvents.SayMessageRequest'] = true,
			['.DefaultChatSystemChatEvents.OnNewMessage'] = true,
			['.ReplicatedStorage.PerspectiveLookEvent'] = true,
			['.ReplicatedStorage.raidRoleplay.Events.RecieveLogs'] = true, -- 4893559188
			['.ReplicatedStorage.ClientBridge.MouseCursor'] = true, -- 6982988368
			['.ReplicatedStorage.WeaponCommunication.CameraUpdated'] = true, -- 6594449288
		}),
	LineBreak = sel(8, '\n'),
	BlockBreak = sel(9, '\n\n'),
	ShowScript = sel(5, false), -- Print out the script that made the remote call (nonfunctional with ProtoSmasher).
	ShowReturns = sel(6, true), -- Display what the remote calls return.
	Output = sel(3, rconsoleprint), -- Function used to output remote calls (rconsoleprint uses Synapse's console).
	ProtectFunction = sel(4, false), -- Set to false in case RSpy crashes for you with certain server events.
}

local metatable = getrawmetatable(game)
local _, make_writeable = next{make_writeable, setreadonly, set_readonly}
local _, detour_function = next{detour_function, replace_closure, hookfunction}
local _, setclipboard = next{setclipboard, set_clipboard, writeclipboard}

local _, get_namecall_method = next{
	get_namecall_method,
	getnamecallmethod,
	function(o) return typeof(o) == 'Instance' and Methods[o.ClassName] or nil end,
}

local _, protect_function = next{
	_G.RSpy_Settings.ProtectFunction and protect_function or nil,
	_G.RSpy_Settings.ProtectFunction and newcclosure or nil,
	function(...) return ... end,
}

local _, get_instances = next{
	getinstances,
	function() return game:GetDescendants() end,
}

_G.RSpy_Original = {}
local Methods = {RemoteEvent = 'FireServer', RemoteFunction = 'InvokeServer'}

local function GetInstanceName(Object) -- Returns proper string wrapping for instances
	local Name = Object.Name
	return
		((#Name == 0 or Name:match('[^%w]+') or Name:sub(1, 1):match('[^%a]')) and
			'["%s"]' or '.%s'):format(Name)
end

local function IsInBlacklist(Object)
	local Path = GetInstanceName(Object)
	if _G.RSpy_Settings.Blacklist[Path:sub(2)] then return true end
	local Parent = metatable.__index(Object, 'Parent')
	while Parent and Parent ~= game do
		Path = GetInstanceName(Parent) .. Path
		if _G.RSpy_Settings.Blacklist[Path] then return true end
		Parent = metatable.__index(Parent, 'Parent')
	end
	return false
end

local function Parse(Object) -- Convert the types into strings
	local Type = typeof(Object)
	if Type == 'string' then
		return ('"%s"'):format(Object)

	elseif Type == 'Instance' then -- Instance:GetFullName() except it's not handicapped
		local Path = GetInstanceName(Object)
		local Parent = metatable.__index(Object, 'Parent')
		while Parent and Parent ~= game do
			Path = GetInstanceName(Parent) .. Path
			Parent = metatable.__index(Parent, 'Parent')
		end
		return (Object:IsDescendantOf(game) and 'game' or 'NIL') .. Path

	elseif Type == 'table' then
		local Str = ''
		local Counter = 0
		for Idx, Obj in next, Object do
			Counter = Counter + 1
			local Obj = Obj ~= Object and Parse(Obj) or 'THIS_TABLE'
			if Counter ~= Idx then
				Str = Str ..
					      ('[%s] = %s, '):format(
						Idx ~= Object and Parse(Idx) or 'THIS_TABLE', Obj) -- maybe
			else
				Str = Str .. ('%s, '):format(Obj)
			end
		end
		return ('{%s}'):format(Str:sub(1, -3))

	elseif Type == 'CFrame' or Type == 'Vector3' or Type == 'Vector2' or Type ==
		'UDim2' or Type == 'Vector3int16' then
		return ('%s.new(%s)'):format(Type, tostring(Object))

	elseif Type == 'Color3' then
		return ('%s.fromRGB(%d, %d, %d)'):format(
			Type, Object.R * 255, Object.G * 255, Object.B * 255)

	elseif Type == 'userdata' then -- Remove __tostring fields to counter traps
		local Result
		local Metatable = getrawmetatable(Object)
		local __tostring = Metatable and Metatable.__tostring
		if __tostring then
			make_writeable(Metatable, false)
			Metatable.__tostring = nil
			Result = tostring(Object)
			rawset(Metatable, '__tostring', __tostring)
			make_writeable(Metatable, rawget(Metatable, '__metatable') ~= nil)
		else
			Result = tostring(Object)
		end
		return Result
	else
		return tostring(Object)
	end
end

-- Remote (Instance), Arguments (Table), Returns (Table)
local function Write(Remote, MethodName, Arguments, Script, Returns)
	_G.RSpy_Settings.Output(
		('%s:%s(%s)'):format(
			Parse(Remote), MethodName, Parse(Arguments):sub(2, -2)))

	if _G.RSpy_Settings.ShowScript and Script then
		if typeof(Script) == 'Instance' then
			_G.RSpy_Settings.Output(
				('%sScript: %s'):format(
					_G.RSpy_Settings.LineBreak, Parse(Script)))
		end
	end
	if _G.RSpy_Settings.ShowReturns and Returns ~= nil and #Returns > 0 then
		_G.RSpy_Settings.Output(
			('%sReturned: %s'):format(
				_G.RSpy_Settings.LineBreak, Parse(Returns):sub(2, -2)))
	end
	_G.RSpy_Settings.Output(_G.RSpy_Settings.BlockBreak)
end

-- Anti-detection for tostring; tostring(FireServer, InvokeServer)
do
	local CURR = tostring
	local ORIG = _G.RSpy_Original[CURR] or CURR
	local NEWF = protect_function(
		function(obj)
			local Success, Result = pcall(
				CURR or original_function, _G.RSpy_Original[obj] or obj)
			if Success then
				return Result
			else
				error(Result:gsub(script.Name .. ':%d+: ', ''))
			end
		end)
	_G.RSpy_Original[CURR] = nil
	_G.RSpy_Original[NEWF] = ORIG
	CURR = detour_function(CURR, NEWF)
end

-- FireServer and InvokeServer hooking; FireServer(Remote, ...)
for Class, Method in next, Methods do
	local CURR = Instance.new(Class)[Method]
	local ORIG = _G.RSpy_Original[CURR] or CURR
	local NEWF = protect_function(
		function(self, ...)
			local Returns = {(ORIG or original_function)(self, ...)}
			if _G.RSpy_Settings.ToServerEnabled and typeof(self) == 'Instance' and
				Methods[self.ClassName] == Method and not IsInBlacklist(self) then

				-- ProtoSmasher HATES getfenv(3); detour_function breaks!
				Write(
					self, Method, {...},
						(_G.RSpy_Settings.ShowScript and not PROTOSMASHER_LOADED) and
							rawget(getfenv(3), 'script') or nil, Returns)
			end
			return unpack(Returns)
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
			local Arguments = {...}
			local Success, Returns = pcall(
				function() return {(ORIG or original_function)(self, unpack(Arguments))} end)
			local Method = get_namecall_method(self)
			if not Success then
				warn(('Method not called successfully: %s [%s]'):format(Method, Returns))
				return
			end
			if _G.RSpy_Settings.ToServerEnabled and typeof(Method) == 'string' and
				Methods[self.ClassName] == Method and not IsInBlacklist(self) then

				-- ProtoSmasher HATES getfenv(3); detour_function breaks!
				Write(
					self, Method, Arguments,
						(_G.RSpy_Settings.ShowScript and not PROTOSMASHER_LOADED) and
							rawget(getfenv(3), 'script') or nil, Returns)
			end
			return unpack(Returns)
		end)
	_G.RSpy_Original[CURR] = nil
	_G.RSpy_Original[NEWF] = ORIG
	make_writeable(metatable, false)
	metatable.__namecall = NEWF
	make_writeable(metatable, true)
end

-- Connect to remotes; Remote:FireClient(...)
do
	local function HookEvent(Remote)
		if Remote.ClassName == 'RemoteEvent' then
			Remote.OnClientEvent:Connect(
				function(...)
					if _G.RSpy_Settings.ToClientEnabled and not IsInBlacklist(Remote) then
						Write(Remote, 'FireClient', {...}, nil, nil)
					end
				end)
		end
	end
	game.DescendantAdded:Connect(HookEvent)
	for _, Object in next, get_instances() do HookEvent(Object) end
end

warn('Settings:')
table.foreach(_G.RSpy_Settings, print)
warn('----------------')

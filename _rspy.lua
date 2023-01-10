---@diagnostic disable: undefined-global
--[[
	Lua U Remote Spy written by chaserks, refactored by VisualPlugin.
	Execution environments supported: Synapse X, ProtoSmasher, WeAreDevs (Sirhurt?, Elysian?)
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
	-- writefile(path, '')
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
			['.ReplicatedStorage.Remotes.Look'] = true, -- 11469138644
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

-- #region patch parse_obj.lua
-- Returns proper string wrapping for instances
local function obj_name(o)
	local n = o.Name:gsub('"', '\\"')
	local f = '.%s'
	if #n == 0 then
		f = '["%s"]'
	elseif n:match('[^%w]+') then
		f = '["%s"]'
	elseif n:sub(1, 1):match('[^%a]') then
		f = '["%s"]'
	end
	return string.format(f, n)
end

local lp = game.Players.LocalPlayer
function get_full(o)
	if not o then return nil end
	local r = parse(obj_name(o))
	local p = o.Parent
	while p do
		if p == game then
			return 'game' .. r
		elseif p == lp then
			return 'game.Players.LocalPlayer' .. r
		end
		r = parse(obj_name(p)) .. r
		p = p.Parent
	end
	return 'NIL' .. r
end

local ARG_REPR_TYPES = { --
	CFrame = true,
	Vector3 = true,
	Vector2 = true,
	Vector3int16 = true,
	Vector2int16 = true,
	UDim2 = true,
}
local SEQ_REPR_TYPES = { --
	ColorSequence = true,
	NumberSequence = true,
}
local SEQ_KEYP_TYPES = { --
	ColorSequenceKeypoint = true,
	NumberSequenceKeypoint = true,
}

local function escape_char(c)
	if c == '\n' then
		return '\\n'
	elseif c == '\r' then
		return '\\r'
	elseif c == '\t' then
		return '\\t'
	elseif c == '\b' then
		return '\\b'
	elseif c == '\f' then
		return '\\f'
	elseif c == '"' then
		return '\\"'
	elseif c == '\\' then
		return '\\\\'
	else
		return string.format('\\u{%x}', c:byte())
	end
end

function parse(obj, nl, lvl) -- Convert the types into strings
	local typ = typeof(obj)
	local lvl = lvl or 0
	if nl == nil then nl = false end

	if typ == 'string' then
		if lvl == 0 then return obj end
		return string.format('"%s"', obj:gsub('[\000-\031%\\"]', escape_char))
	end

	-- Instance:GetFullName() except it's not handicapped
	if typ == 'Instance' then return get_full(obj) end

	if typ == 'table' then
		if lvl > 666 then return 'DEEP_TABLE' end
		local keyed_vals = {}
		local ipair_vals = {}
		local tab = '  '
		local c = 0

		local ws_zer = ' '
		local ws_beg = ' '
		local ws_cat = ' '
		local ws_end = ' '
		local sep = ','
		if nl then
			ws_beg = string.format('\n%s', string.rep(tab, lvl + 1))
			ws_cat = string.format('\n%s', string.rep(tab, lvl + 1))
			ws_end = string.format('\n%s', string.rep(tab, lvl))
			ws_zer = string.format('\n%s', string.rep(tab, lvl))
		end

		for i, o in next, obj do
			c = c + 1

			local o_str
			if o ~= obj then
				o_str = parse(o, nl, lvl + 1)
			else
				o_str = 'THIS_TABLE'
			end

			if c == i then
				table.insert(ipair_vals, string.format('%s%s', o_str, sep))
			else
				local i_str = i ~= obj and parse(i, nl, lvl + 1) or 'THIS_TABLE'
				table.insert(keyed_vals, string.format('[%s] = %s%s', i_str, o_str, sep))
			end
		end

		-- Merges keyed values with ipair values - in that order.
		table.sort(keyed_vals)
		table.move(ipair_vals, 1, #ipair_vals, #keyed_vals + 1, keyed_vals)
		if #keyed_vals == 0 then return string.format('{%s}', ws_zer) end

		local all_str = table.concat(keyed_vals, ws_cat)
		return string.format('{%s%s%s}', ws_beg, all_str, ws_end)
	end

	if ARG_REPR_TYPES[typ] then
		local f_args = {typ, tostring(obj):gsub('[{}]', '')}
		return string.format('%s.new(%s)', unpack(f_args))
	end

	if SEQ_REPR_TYPES[typ] then
		local f_args = {typ, parse(obj.Keypoints, nl, lvl)}
		return string.format('%s.new(%s)', unpack(f_args))
	end

	if SEQ_KEYP_TYPES[typ] then
		local f_args = {typ, obj.Time, parse(obj.Value, nl, lvl)}
		return string.format('%s.new(%s, %s)', unpack(f_args))
	end

	if typ == 'Color3' then
		local f_args = {typ, obj.R * 255, obj.G * 255, obj.B * 255}
		return string.format('%s.fromRGB(%d, %d, %d)', unpack(f_args))
	end

	if typ == 'NumberRange' then
		local f_args = {typ, tostring(obj.Min), tostring(obj.Max)}
		return string.format('%s.new(%s, %s)', unpack(f_args))
	end

	if typ == 'userdata' then
		local res
		local meta = getrawmetatable(obj)
		local m_ts = meta and meta.__tostring
		-- Remove __tostring fields to counter traps.
		if m_ts then
			setreadonly(meta, false)
			meta.__tostring = nil
			res = tostring(obj)
			rawset(meta, '__tostring', m_ts)
			setreadonly(meta, rawget(meta, '__metatable') ~= nil)
		else
			res = tostring(obj)
		end
		return res
	end

	return tostring(obj)
end
-- #endregion patch

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

local function write(remote, format, arguments, script, returns)
	local a_s = parse(arguments):sub(3, -4)
	local line = string.format(format, parse(remote), a_s)
	SETTINGS.Output(line)

	if SETTINGS.ShowScript and script then
		if typeof(script) == 'Instance' then
			local s = string.format('%sScript: %s', SETTINGS.LineBreak, parse(script))
			SETTINGS.Output(s)
		end
	end
	if SETTINGS.ShowReturns and returns and #returns > 0 then
		local r_s = parse(returns):sub(3, -4)
		local s = string.format('%sReturned: %s', SETTINGS.LineBreak, r_s)
		SETTINGS.Output(s)
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
	local format = string.format('%%s:%s( %%s )', method_n)
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

--[[
warn('Settings:')
table.foreach(SETTINGS, print)
warn('----------------')
]]

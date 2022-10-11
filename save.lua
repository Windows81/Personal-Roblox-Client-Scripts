--[==[HELP]==
[1] - string | boolean | nil
	The relative file path to save to.

[2] - any
	The object to parse and save to a file.

[3] - string | nil
	The suffix to add to the string.

[4] - boolean | nil
	If true, append the file instead of overwriting.
]==] --
--
local _, make_writeable = next{make_writeable, setreadonly, set_readonly}

local args = _E.ARGS
local FILE = args[1] or 'temp.txt'
local VALUE = args[2]
local SUFFIX = args[3] or ''
local APPEND = args[4]

local function get_name(o) -- Returns proper string wrapping for instances
	local n = o.Name:gsub('"', '\\"')
	local f = '.%s'
	if #n == 0 then
		f = '["%s"]'
	elseif n:match('[^%w]+') then
		f = '["%s"]'
	elseif n:sub(1, 1):match('[^%a]') then
		f = '["%s"]'
	end
	return f:format(n)
end

local lp = game.Players.LocalPlayer
function get_full(o)
	if not o then return nil end
	local r = parse(get_name(o))
	local p = o.Parent
	while p do
		if p == game then
			return 'game' .. r
		elseif p == lp then
			return 'game.Players.LocalPlayer' .. r
		end
		r = parse(get_name(p)) .. r
		p = p.Parent
	end
	return 'NIL' .. r
end

local PARAM_REPR_TYPES = {
	CFrame = true,
	Vector3 = true,
	Vector2 = true,
	UDim2 = true,
	Vector3int16 = true,
	Vector2int16 = true,
}
local SEQ_REPR_TYPES = { --
	ColorSequence = true,
	NumberSequence = true,
}
local SEQ_KEYP_TYPES = { --
	ColorSequenceKeypoint = true,
	NumberSequenceKeypoint = true,
}

function parse(obj, lvl) -- Convert the types into strings
	local t = typeof(obj)
	local lvl = lvl or 0
	if t == 'string' then
		if lvl == 0 then return obj end
		return ('"%s"'):format(
			obj:gsub(
				'.', { --
					['\n'] = '\\n',
					['\t'] = '\\t',
					['\0'] = '\\0',
					['\1'] = '\\1',
				}))

	elseif t == 'Instance' then -- Instance:GetFullName() except it's not handicapped
		return get_full(obj)

	elseif t == 'table' then
		local alpha_vals = {}
		local ipair_vals = {}
		local c = 0
		local tab = '  '
		if lvl > 666 then return 'DEEP_TABLE' end

		for i, o in next, obj do
			c = c + 1
			local o_str = o ~= obj and parse(o, lvl + 1) or 'THIS_TABLE'
			local ws = string.format('\n%s', string.rep(tab, lvl + 1))
			if c ~= i then
				local i_str = i ~= obj and parse(i, lvl + 1) or 'THIS_TABLE'
				table.insert(alpha_vals, ('%s[%s] = %s,'):format(ws, i_str, o_str))
			else
				table.insert(ipair_vals, ('%s%s,'):format(ws, o_str))
			end
		end
		table.sort(alpha_vals)
		local alpha_str = table.concat(alpha_vals, '')
		local ipair_str = table.concat(ipair_vals, '')
		return ('{%s%s\n%s}'):format(ipair_str, alpha_str, string.rep(tab, lvl))

	elseif PARAM_REPR_TYPES[t] then
		return ('%s.new(%s)'):format(t, tostring(obj))

	elseif SEQ_REPR_TYPES[t] then
		return ('%s.new %s'):format(t, parse(obj.Keypoints, lvl))

	elseif SEQ_KEYP_TYPES[t] then
		return ('%s.new(%s, %s)'):format(t, tostring(obj.Time), parse(obj.Value, lvl))

	elseif t == 'Color3' then
		return ('%s.fromRGB(%d, %d, %d)'):format(
			t, obj.R * 255, obj.G * 255, obj.B * 255)

	elseif t == 'NumberRange' then
		return ('%s.new(%s, %s)'):format(t, tostring(obj.Min), tostring(obj.Max))

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

local p = parse(VALUE) .. SUFFIX
if APPEND then
	appendfile(FILE, p)
else
	writefile(FILE, p)
end

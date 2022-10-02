local _, make_writeable = next{make_writeable, setreadonly, set_readonly}

local function get_name(o) -- Returns proper string wrapping for instances
	local n = o.Name
	local f = '.%s'
	if #n == 0 or n:match('[^%w]+') or n:sub(1, 1):match('[^%a]') then f = '["%s"]' end
	return f:format(n)
end

local lp = game.Players.LocalPlayer
function get_full(o)
	if not o then return nil end
	local r = parse(get_name(o)):sub(2, -2)
	local p = o.Parent
	while p do
		r = parse(get_name(p)):sub(2, -2) .. r
		p = p.Parent
		if p == game then
			return 'game' .. r
		elseif p == lp then
			return 'game.Players.LocalPlayer' .. r
		end
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
	if t == 'string' then
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
		local lvl = lvl or 0
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

local args = _G.EXEC_ARGS
local output = print
if typeof(args[1]) == 'function' then
	output = args[1]
	table.remove(args, 1)
end

local concat = {}
for _, o in args do table.insert(concat, parse(o)) end
output(table.concat(concat, ' '))
_G.EXEC_RETURN = args

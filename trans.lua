--[==[HELP]==
Traverses through a list of Instance objects, with the full path and number of layers from the datamodel printed out.

[1] - {Instance} | Instance | nil
	List of objects to be traversed.
	If passed as a single instance, all its descendants are included in the range.

[2, ...] - (any)->any | string
	If passed in as a function object, performs the operation as dictated by previous arguments.
	If passed in as a string: such that the order of the flags determines where return values correspond to which operation.

]==] --
--
local args = _E and _E.ARGS or {}
local RANGE = args[1] or game
if typeof(RANGE) == 'Instance' then RANGE = RANGE:GetDescendants() end
local STEPS = {unpack(args, 2)}

local function trans(range, mode, func)
	local ret_table = {}
	for i, v in next, range do
		local res = {func(v, i)}
		local flag_i = 1
		local ret_value = v
		local include = true
		for m in mode:gmatch('[_a-z]') do
			local flag_ret = res[flag_i]
			if m == 'f' then
				if not res then
					include = false
					break
				end
			elseif m == 'm' then
				ret_value = flag_ret
			end
			flag_i = flag_i + 1
		end
		if include then ret_table[i] = ret_value end
	end
	return ret_table
end

local mode = 'm'
local res = table.clone(RANGE)
for _, s in next, STEPS do
	if typeof(s) == 'string' then
		mode = s:lower()
	else
		res = trans(res, mode, s)
	end
end
return res

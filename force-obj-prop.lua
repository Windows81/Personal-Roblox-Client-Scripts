local args = _G.EXEC_ARGS or {}
local PROP_NAME = args[1]
local FILTER_FUNC = args[2]
local MAKE_BIGGER = args[3]
if MAKE_BIGGER == nil then MAKE_BIGGER = true end

_G.oprop_cache = _G.oprop_cache or {}
local cache = _G.oprop_cache
cache[PROP_NAME] = cache[PROP_NAME] or {}
local prop_cache = cache[PROP_NAME]

local function fill_props(t)
	t = t or {}
	t.filter_func, t.factor = FILTER_FUNC, 0x10000
	if t.make_bigger == nil then t.make_bigger = MAKE_BIGGER end
	return t
end

local function multiply(o, prop) o[prop] = o[prop] * cache[prop].PROPS.factor end
local function divide(o, prop) o[prop] = o[prop] / cache[prop].PROPS.factor end
prop_cache.PROPS = fill_props(prop_cache.PROPS)

local function changed(o, prop)
	local cache = cache[prop]
	local v = o[prop]
	if cache.PROPS.make_bigger then
		while v * v < cache.PROPS.factor do
			v = v * cache.PROPS.factor
			--
		end
	else
		while v * v >= 1 / cache.PROPS.factor do
			v = v / cache.PROPS.factor
			--
		end
	end
	o[prop] = v
end

local function extend(o)
	for prop, cache in next, cache do
		local f = cache.PROPS.filter_func
		if f and f(o) then
			if cache.PROPS.make_bigger then
				multiply(o, prop)
			else
				divide(o, prop)
			end
			cache[o] = o:GetPropertyChangedSignal(prop):Connect(
				function() changed(o, prop) end)
		end
	end
end

local function restore(o)
	for prop, cache in next, cache do
		if cache[o] then
			cache[o]:Disconnect()
			cache[o] = nil
			print(o, o[prop])
			if cache.PROPS.make_bigger then
				divide(o, prop)
			else
				multiply(o, prop)
			end
			print(o, o[prop])
		end
	end
end

for o, _ in next, prop_cache do if type(o) ~= 'string' then restore(o) end end
if FILTER_FUNC then
	for _, o in next, game:GetDescendants() do extend(o) end
else
	cache[PROP_NAME] = nil
end

if _G.oprop_evt then _G.oprop_evt:Disconnect() end
_G.oprop_evt = game.DescendantAdded:Connect(extend)

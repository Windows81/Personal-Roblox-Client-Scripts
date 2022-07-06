--[==[HELP]==
[1] - {Instance} | Instance
	List of objects to perform operation on.

[2] - {[string]: any}
	Properties to which each object should tween to.
	If value is a table with two elements, snap to index [1] then tween to index [2].

[3] - TweenInfo | number | nil
	TweenInfo object with which the object can be tweened.
	If a number is passed in, perform a linear tween with the specified duration.
]==] --
--
local args = _G.EXEC_ARGS or {}
local ts = game:GetService 'TweenService'
local ev = Instance.new'BindableEvent'
local tk = tick()

local OBJECTS = args[1]
if not OBJECTS then
	OBJECTS = {}
elseif typeof(OBJECTS) == 'Instance' then
	OBJECTS = {OBJECTS}
end

local PROPS = args[2]
if not PROPS then PROPS = {} end

local TWEEN_INFO = args[3]
if not TWEEN_INFO then
	TWEEN_INFO = TweenInfo.new()
elseif typeof(TWEEN_INFO) == 'number' then
	TWEEN_INFO = TweenInfo.new(TWEEN_INFO, Enum.EasingStyle.Linear)
end

local pre = {}
for i, p in next, PROPS do
	local isFromTo = typeof(p) == 'table' and #p == 2
	if isFromTo then pre[i], PROPS[i] = unpack(p) end
end

if TWEEN_INFO.Time <= 0 then
	if TWEEN_INFO.DelayTime > 0 then --
		wait(TWEEN_INFO.DelayTime)
	end
	for _, o in next, OBJECTS do
		for i, p in next, PROPS do o[i] = p end --
	end
	return
end

local count = 0
for _, o in next, OBJECTS do
	count = count + 1
	for i, p in next, pre do o[i] = p end
	local tw = ts:Create(o, TWEEN_INFO, PROPS)
	tw:Play()
	tw.Completed:Connect(
		function()
			count = count - 1
			if count == 0 then ev:Fire(tick() - tk) end
		end)
end

local d = ev.Event:Wait()
_G.EXEC_RETURN = {d}

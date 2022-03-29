local args = _G.EXEC_ARGS or {}

local function GetInstanceName(Object)
	local Name = Object.Name
	return
		((#Name == 0 or Name:match('[^%w]+') or Name:sub(1, 1):match('[^%a]')) and
			'["%s"]' or '.%s'):format(Name)
end

local function Parse(Object)
	local Path = GetInstanceName(Object)
	local Parent = Object.Parent
	while Parent and Parent ~= game do
		Path = GetInstanceName(Parent) .. Path
		Parent = Parent.Parent
	end
	return (Object:IsDescendantOf(game) and 'game' or 'NIL') .. Path
end

local m = game.Players.LocalPlayer:GetMouse()
if args[1] then
	wait(args[1])
else
	m.Button1Up:Wait()
end
print(Parse(m.Target))

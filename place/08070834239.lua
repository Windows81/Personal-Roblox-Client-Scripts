function e(n, i)
	local d = game.Workspace.Doors.Normal:FindFirstChild(tostring(n))
	if not d then return end
	local s = d.Door:FindFirstChild(tostring(i))
	if not s then return end
	return s.SurfaceGui.Element
end

function f(n)
	local o = e(n, 2).Image
	local a
	-- error(o)
	if o == 'rbxassetid://8839724425' then
		a = e(n, 1).Text - e(n, 3).Text
	elseif o == 'rbxassetid://8839724292' then
		a = e(n, 1).Text + e(n, 3).Text
	elseif o == 'rbxassetid://8839724578' then
		a = e(n, 1).Text * e(n, 3).Text
	elseif o == 'rbxassetid://8935988667' then
		a = e(n, 1).Text / e(n, 3).Text
	end
	return a
end

local i = 1
local a
repeat
	a = f(i)
	game.ReplicatedStorage.Events.SubmitAnswer:FireServer(tostring(a))
	i = i + 1
until not a

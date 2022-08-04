local args = _G.EXEC_ARGS or {}
print'Ensure the copy tool is being used!'

local function clone(p, i)
	local s, k, p =
		game.ReplicatedStorage.ClientBridge.DragControlIer:InvokeServer(
			'GetKey', p, true)
	if s then
		game.ReplicatedStorage.ClientBridge.DragControlIer.Update:FireServer(
			'Update', k, p.CFrame * CFrame.new(i * args[2]))
		game.ReplicatedStorage.ClientBridge.DragControlIer.Update:FireServer(
			'ClearKey', k)
	end
	return s
end

if args[1] == 'clone' then
	for i = 1, args[3] do
		for _, p in next, _G.pt do
			clone(p, i)
			task.wait(args[4] or .15)
		end
	end

elseif args[1] == 'test' then
	clone(_G.pt[1], args[3])

elseif args[1] == 'halt' then
	local d = game.ReplicatedStorage.ClientBridge.DragControlIer
	d.Name = '666'
	task.wait(args[4] or 1)
	d.Name = 'DragControlIer'
end

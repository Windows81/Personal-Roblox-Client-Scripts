--[[
for i = 1, 27 do
	for _, p in next, _G.pt do
		local s, k, p =
			game.ReplicatedStorage.ClientBridge.DragControlIer:InvokeServer(
				'GetKey', p, true)
		if s then
			game.ReplicatedStorage.ClientBridge.DragControlIer.Update:FireServer(
				'Update', k, p.CFrame * CFrame.new(0, 16 * i, 0))
			game.ReplicatedStorage.ClientBridge.DragControlIer.Update:FireServer(
				'ClearKey', k)
		end
		wait(.1)
		-- break
	end
	-- break
end
]] --[[
local d=game.ReplicatedStorage.ClientBridge.DragControlIer
d.Name='666'
wait(1)
d.Name='DragControlIer'
]] 

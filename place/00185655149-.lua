-- https://github.com/vozoid/scripts/blob/c64c575a35507014a260f5af557dd1296ab3c9ba/bloxburg.lua
_G.blx_hair = tick()
local tik = _G.blx_hair

if not firesignal then
	firesignal = function(btn)
		for _, e in next, getconnections(btn) do e:Fire() end
	end
end

local hairs = {
	Afro = 11412443,
	Charming = 74878559,
	Combed = 13332444,
	Headband = 13070796,
	Pigtails = 82186393,
	Messy = 26400959,
	Bun = 47963332,
	Long = 19999424,
	Curly = 31309506,
	Sideswept = 16627529,
}

local colors = {
	Gray = BrickColor.new'Pearl',
	Blonde = BrickColor.new'Gold',
	Brown = BrickColor.new'Burnt Sienna',
	Black = BrickColor.new'Black',
	Red = BrickColor.new'Crimson',
	Blue = BrickColor.new'Bright blue',
	Green = BrickColor.new'Lime green',
	Pink = BrickColor.new'Hot pink',
}

local rs = game:GetService 'ReplicatedStorage'
local client = game:GetService 'Players'.LocalPlayer

local stats = rs.Stats[client.Name]
local jobManager = require(client.PlayerGui.MainGUI.Scripts.JobHandler)

function get_order(customer)
	return {
		Customer = customer,
		Style = customer.Order:WaitForChild 'Style'.Value,
		Color = customer.Order:WaitForChild 'Color'.Value,
	}
end

function style_matches(order)
	local mesh = order.Customer.PrimaryHat.Handle.Mesh
	return mesh.MeshId:split 'id='[2] == tostring(hairs[order.Style])
end

function color_matches(order)
	return order.Customer.PrimaryHat.Handle.BrickColor == colors[order.Color]
end

if stats.Job.Value ~= 'StylezHairdresser' then
	jobManager:GoToWork 'StylezHairdresser'
end

while tik == _G.blx_hair do
	local locations = game.workspace.Environment.Locations
	local studio = locations:WaitForChild 'StylezHairStudio'
	local workstations = studio:WaitForChild 'HairdresserWorkstations'
	task.wait()

	for _, station in next, workstations:GetChildren() do
		local frame = station.Mirror.HairdresserGUI.Frame
		if station.InUse.Value == client then
			local customer = station.Occupied.Value
			if customer then
				local bubble = customer:WaitForChild 'Head':WaitForChild('ChatBubble', 7)
				if bubble then
					task.wait()
					local order = get_order(customer)
					if not style_matches(order) or not color_matches(order) then
						local style_sig = frame:FindFirstChild 'Style'.Next.Activated
						repeat firesignal(style_sig) until customer and style_matches(order)

						task.wait()
						if customer then
							local color_sig = frame:FindFirstChild 'Color'.Next.Activated
							repeat firesignal(color_sig) until customer and color_matches(order)

							task.wait()
							firesignal(frame:FindFirstChild 'Done'.Activated)
						end
					end
				end
			end
		else
			local do_fire = true
			for i, c in next, workstations:GetChildren() do
				if i > 4 then break end
				if c.InUse.Value == client then
					do_fire = false
					break
				end
			end
			if do_fire then
				firesignal(frame:FindFirstChild 'Style'.Next.Activated)
				firesignal(frame:FindFirstChild 'Color'.Next.Activated)
			end
		end
	end
end

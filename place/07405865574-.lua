--[==[HELP]==
To be used with "[BUILD] Pixels!" by Programmed Games.
]==] --
--
---@diagnostic disable: undefined-global
function f(p, W1, W2, H, S)
	local B = 4
	local p = p * CFrame.new(-B * W1 / 2, 0, -B * W2 / 2)
	assert(
		make{
			[{'navy_blue_block'}] = join{ --
				p * CFrame.new(0, 0, B) * CFrame.Angles(0, math.pi / 2, 0),
			},
		})

	void(
		join{
			box3(
				p * CFrame.new(B * (000000), B * (0), B * (000001)), B, 000000, 2, 000000),
			box3(
				p * CFrame.new(B * (W1 - 2), B * (1), B * (000001)), B, 0000, H * S, 0001),
		})

	local h = {
		[{'navy_blue_block'}] = join{
			frme(
				p * CFrame.new(B * (000000), B * (0), B * (000000)), B, W1 - 1, 0, W2 - 1),
			frme(
				p * CFrame.new(B * (000000), B * (1), B * (000000)), B, W1 - 1, 0, W2 - 1),
			box3(
				p * CFrame.new(B * (000000), B * (2), B * (000000)), B, 000000, 2, 000000),
			box3(
				p * CFrame.new(B * (W1 - 1), B * (2), B * (000000)), B, 000000, 2, 000000),
			box3(
				p * CFrame.new(B * (000000), B * (2), B * (W2 - 1)), B, 0000, H - 2, 0000),
			box3(
				p * CFrame.new(B * (W1 - 1), B * (2), B * (W2 - 1)), B, 0000, H - 2, 0000),
			frme(
				p * CFrame.new(B * (000000), B * (H), B * (000000)), B, W1 - 1, 0, W2 - 1),
		},
		[{'red_block'}] = join{
			box3(
				p * CFrame.new(B * (000001), B * (0), B * (000001)), B, W1 - 3, 0, W2 - 3),
		},
	}

	for s = 0, S - 1 do
		for data, cfs in next, h do
			assert(make(shft(cfs, CFrame.new(0, H * s * B, 0)), unpack(data)))
		end
	end

	for data, cfs in next, {
		[{'red_block'}] = join{
			box3(
				p * CFrame.new(B * (000001), B * (0), B * (000001)), B, W1 - 3, 0, W2 - 3),
		},
		[{'navy_blue_block'}] = join{
			frme(
				p * CFrame.new(B * (-000.5), B * (1), B * (-000.5)), B, W1 - 0, 0, W2 - 0),
		},
	} do assert(make(shft(cfs, CFrame.new(0, H * S * B, 0)), unpack(data))) end
end

math.randomseed(666)
for a = 0, 360 - 1e-2, 30 do
	f(CFrame.new(296, 4, 888), 4, 4, 5, 3)
	break
end

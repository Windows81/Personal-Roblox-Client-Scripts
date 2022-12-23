---@diagnostic disable: undefined-global
function f(p, B, W1, W2, H, S)
	for typ, cfs in next, {
		['Steps'] = { --
			p * CFrame.new(.9, 0, B),
		},
	} do make(cfs, typ) end

	void(
		join{
			box3(
				p * CFrame.new(B * (000000), B * (0), B * (000001)), B, 000000, 2, 000000),
			box3(
				p * CFrame.new(B * (W1 - 2), B * (1), B * (000001)), B, 0000, H * S, 0000),
		})

	local h = {
		['Ladder'] = join{
			box3(
				p * CFrame.new(B * (W1 - 1.6), B * (1), B * (00.5)), B, 000000, H, 000000),
		},
		['Block - Sand'] = join{
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
		['Block - Red'] = join{
			box3(
				p * CFrame.new(B * (000001), B * (0), B * (000001)), B, W1 - 3, 0, W2 - 3),
		},
	}
	for s = 0, S - 1 do
		for typ, cfs in next, h do make(shft(cfs, CFrame.new(0, H * s * B, 0)), typ) end
	end

	for typ, cfs in next, {
		['Block - Red'] = join{
			box3(p * CFrame.new(B * (000001), B * H, B * (000001)), B, W1 - 3, 0, W2 - 3),
		},
	} do make(shft(cfs, CFrame.new(0, H * (S - 1) * B, 0)), typ) end
end

local B = 4
local W1 = 4
local W2 = 4
for x = -40, 23, (W1 + 1) * B do
	local H = math.random(4, 5)
	local S = math.random(1, 7)
	local p = CFrame.new(-x, 23.5, -106) * CFrame.Angles(0, -math.pi / 2, 0)
	f(p, B, W1, W2, H, S)
end

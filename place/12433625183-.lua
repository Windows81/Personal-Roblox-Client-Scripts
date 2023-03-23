--[==[HELP]==
To be used with "Doodle Transform!".
]==] --
--
local COLOUR = Color3.fromRGB(0, 120, 215)
local CHARACTERS = { --
	['0'] = { --
		{x = 00, y = 08, r = 90, s = 12},
		{x = 06, y = 08, r = 90, s = 12},
		{x = 03, y = 00, r = 00, s = 06},
		{x = 03, y = 16, r = 00, s = 06},
	},
	['1'] = { --
		{x = 06, y = 08, r = 90, s = 13},
	},
	['2'] = { --
		{x = 00, y = 12, r = 90, s = 06},
		{x = 06, y = 04, r = 90, s = 06},
		{x = 03, y = 00, r = 00, s = 06},
		{x = 03, y = 08, r = 00, s = 06},
		{x = 03, y = 16, r = 00, s = 06},
	},
	['3'] = { --
		{x = 06, y = 08, r = 90, s = 12},
		{x = 03, y = 00, r = 00, s = 06},
		{x = 03, y = 08, r = 00, s = 06},
		{x = 03, y = 16, r = 00, s = 06},
	},
	['4'] = { --
		{x = 00, y = 04, r = 90, s = 06},
		{x = 06, y = 08, r = 90, s = 12},
		{x = 03, y = 08, r = 00, s = 06},
	},
	['5'] = { --
		{x = 00, y = 04, r = 90, s = 06},
		{x = 06, y = 12, r = 90, s = 06},
		{x = 03, y = 00, r = 00, s = 06},
		{x = 03, y = 08, r = 00, s = 06},
		{x = 03, y = 16, r = 00, s = 06},
	},
	['6'] = { --
		{x = 00, y = 08, r = 90, s = 12},
		{x = 06, y = 12, r = 90, s = 06},
		{x = 03, y = 00, r = 00, s = 06},
		{x = 03, y = 08, r = 00, s = 06},
		{x = 03, y = 16, r = 00, s = 06},
	},
	['7'] = { --
		{x = 06, y = 08, r = 90, s = 12},
		{x = 03, y = 00, r = 00, s = 06},
	},
	['8'] = { --
		{x = 00, y = 08, r = 90, s = 12},
		{x = 06, y = 08, r = 90, s = 12},
		{x = 03, y = 00, r = 00, s = 06},
		{x = 03, y = 08, r = 00, s = 06},
		{x = 03, y = 16, r = 00, s = 06},
	},
	['9'] = { --
		{x = 00, y = 04, r = 90, s = 06},
		{x = 06, y = 08, r = 90, s = 12},
		{x = 03, y = 00, r = 00, s = 06},
		{x = 03, y = 08, r = 00, s = 06},
		{x = 03, y = 16, r = 00, s = 06},
	},
	[':'] = { --
		{x = 00, y = 04, r = 90, s = 02},
		{x = 00, y = 12, r = 90, s = 02},
	},
	['u'] = { --
		{x = 00, y = 04, r = 90, s = 06},
		{x = 04, y = 04, r = 90, s = 06},
		{x = 02, y = 08, r = 00, s = 05},
	},
	['t'] = { --
		{x = 02, y = 05, r = 90, s = 06},
		{x = 02, y = 01, r = 00, s = 04},
	},
	['c'] = { --
		{x = 00, y = 04, r = 90, s = 06},
		{x = 02, y = 01, r = 00, s = 04},
		{x = 02, y = 08, r = 00, s = 04},
	},
}

local function setup()
	game.ReplicatedStorage.Remotes.GUI:FireServer('DrawingStatus', true)
	game.ReplicatedStorage.Remotes.Request:InvokeServer('ClearCanvas')
end

local function finish()
	game.ReplicatedStorage.Remotes.GUI:FireServer('DrawingStatus', false)
	game.ReplicatedStorage.Remotes.Request:InvokeServer('ApplyInk')
end

local function place(t)
	return game.ReplicatedStorage.Remotes.Request:InvokeServer('PlaceInkBulk', t)
end

local function char(n, x, y)
	local r = {}
	for _, t in next, CHARACTERS[n] do
		table.insert(
			r, {
				['Color'] = COLOUR,
				['Depth'] = 1 / 2,
				['Name'] = 'Ink',
				['Position'] = UDim2.new(t.x / 32 + x, 0, t.y / 32 + y, 0),
				['Size'] = UDim2.new(t.s / 32, 0, 1 / 16, 0),
				['Rotation'] = t.r,
			})
	end
	return r
end

function process(s)
	setup()

	local i = 1
	local offsets = {0, 8, 18, 26}
	for d in string.gmatch(s, '%d') do
		place(char(d, offsets[i] / 32, 0))
		i = i + 1
	end

	place(char(':', 08 / 16, 0))
	place(char('u', 04 / 16, 5 / 8))
	place(char('t', 07 / 16, 5 / 8))
	place(char('c', 10 / 16, 5 / 8))

	finish()
end

local prev_ds
function loop()
	local t = tick() + 4
	local ds = os.date('%H%M', t)
	if prev_ds ~= ds then
		prev_ds = ds
		process(ds)
	end
end

if _G.tmdd_t then
	_G.tmdd_t:Disconnect()
	_G.tmdd_t = nil
else
	_G.tmdd_t = game:GetService 'RunService'.Heartbeat:Connect(loop)
end

local COLS = 2

local cache = {}
function get(r, c)
	local o = game.Workspace.Guess:FindFirstChild(tostring(r))
	if not o then return end
	cache[r] = cache[r] or {}
	if cache[r][c] then return cache[r][c] end
	local p = '^' .. c
	for i, g in next, o:GetChildren() do
		if g.ClassName == 'Part' and g.Position.Z == 18 - c * 12 then
			cache[r][c] = g
			return g
		end
	end
end

if _G.sqge then
	for r, t in next, _G.sqge do for c, e in next, t do e:Disconnect() end end
end

local chrs = {}
local vlds = {}
local evts = {}
_G.sqge = evts
_G.sqgv = vlds

function save(r, c) vlds[r] = get(r, c) end

local R = 0
while R >= 0 do
	R = R + 1
	local r = R
	evts[r] = {}

	for c = 1, COLS do
		local o = get(r, c)
		if not o or R < 0 then
			R = -1
			break
		end
		evts[r][c] = o.Touched:connect(
			function(p)

				local ch = p.Parent
				local h = ch:FindFirstChild 'Humanoid'
				if not h then return end

				local hrp = ch:FindFirstChildWhichIsA 'Humanoid'.RootPart.Position
				task.wait(1.5)
				local hrd = ch:FindFirstChildWhichIsA 'Humanoid'.RootPart.Position - hrp
				local hl = h.Health > 0
				local mg = hrd.Magnitude < 28
				local mr = (chrs[ch] or -1) >= r

				if hl and mg and mr then
					for C = 1, COLS do evts[r][C]:Disconnect() end
					save(r, c)
				elseif (not hl or not mg) and COLS == 2 then
					save(r, 3 - c)
				end
				chrs[ch] = r

			end)
	end
end

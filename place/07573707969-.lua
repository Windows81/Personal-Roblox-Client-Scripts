local entries = {}
local pnts_avail = 0
for _, pl in next, game.Players:children() do
	local l = pl:findFirstChild 'leaderstats'
	if l then
		local val = l.Words.Value
		local entry = {value = val, player = pl}
		table.insert(entries, entry)
		if pl == game.Players.LocalPlayer then pnts_avail = val end
	end
end

function give(entry, set_pnts)
	local diff = set_pnts - entry.value
	print(entry.player.DisplayName, diff)
	if diff <= 0 then return end
	local args = {entry.player.Name, tostring(diff)}
	game.ReplicatedStorage.Remotes.GiveWords:InvokeServer(unpack(args))
end

-- Sort entries in ascending order.
table.sort(entries, function(a, b) return a.value < b.value end)

local recip_max = 0
local recip_num = -1
local recip_sum = 0
for _, st in next, entries do
	local t_max = st.value
	local t_sum = recip_sum + t_max
	local t_num = recip_num + 1
	local rem = pnts_avail - (t_max * t_num - t_sum)
	if rem < 0 then break end
	recip_max = t_max
	recip_sum = t_sum
	recip_num = t_num
end

for i = recip_num, 1, -1 do give(entries[i], recip_max) end

--[==[HELP]==
[1] - string | nil
	The webhook URL.

[2] - string | boolean | nil
	If set to true or not passed in, writes to a file to path formatted as "./logs/%011(placeId) %Y-%m-%d %H%M%S.txt".
]==] --
--
-- I am NOT sorry for revealling my webhook URL to the public.
-- I am an ardent supporter for the hacker spirit.
-- If that means having other people mess with my logs, so be it.
local DEFAULT_WEBHOOK = nil
--[[https://discord.com/api/webhooks/1036429230910738443/9CabVFH-m904S_n1cVP-2D5_qCa3ECXNt7Lkr0kIS0nLmK4jVBmDDn_T68y1lIIVArOT]]

local args = _E and _E.ARGS or {}
local WEBHOOK = args[1]
local FILEPATH = args[2]
local APPENDS_INSTEAD_OF_WRITES = args[3]
local WRITES_FILE_AT_ONCE = args[4]
local TICK_DELAY = args[5]

if WEBHOOK == nil then WEBHOOK = DEFAULT_WEBHOOK end
if WEBHOOK then
	if WEBHOOK:find 'discorda?p*%.com/api/webhooks/' then
		local split = WEBHOOK:split('/')
		local len = #split
		WEBHOOK = string.format('%s/%s', split[len - 1], split[len])
	end
	WEBHOOK = 'https://discord.com/api/webhooks/' .. WEBHOOK
end

if APPENDS_INSTEAD_OF_WRITES == nil then APPENDS_INSTEAD_OF_WRITES = true end
if WRITES_FILE_AT_ONCE == nil then WRITES_FILE_AT_ONCE = false end
if TICK_DELAY == nil then TICK_DELAY = 7 end

local pls = game:GetService 'Players'
local rs = game:GetService 'ReplicatedStorage'
local dsce = rs:FindFirstChild 'DefaultChatSystemChatEvents'

local place_id = game.PlaceId
local svr_id = #game.JobId > 0 and game.JobId or 'PLAYTEST'
local lp_uid = pls.LocalPlayer.UserId
local enabled = true

local http_req_hook
local plr_from_id_hook = pls.GetPlayerByUserId
local function timestamp(t) return os.date('%Y-%m-%dT%H:%M:%SZ', t) end

local function get_place_name(pId)
	local s, r = pcall(
		game.MarketplaceService.GetProductInfo, game.MarketplaceService, pId)
	return (s and r) and r.Name or nil
end

local place_name = get_place_name(place_id)
if not place_name then
	place_name = ''
	task.spawn(
		function()
			local n
			repeat
				task.wait(3)
				n = get_place_name(place_id)
			until n
			place_name = n
		end)
end

local HEADER = string.format(
	'[%11s] : [%11s] %s - %s', lp_uid, place_id, place_name, svr_id)
_G.wh_log_long = HEADER
_G.wh_log_snip = ''

if type(FILEPATH) ~= 'string' and FILEPATH ~= false then
	FILEPATH = string.format(
		'logs/%011d %s.txt', place_id, os.date('%Y-%m-%d %H%M%S'))
	makefolder('logs')
	if FILEPATH then writefile(FILEPATH, HEADER) end
end

function hrp_pos_str(ch)
	if ch then
		local hrp = ch:FindFirstChild 'HumanoidRootPart'
		if hrp then
			return string.format(
				' (%7.1f, %7.1f, %7.1f)', hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
		end
	end
	return ''
end

function plr_header(pl, disp)
	local uid = pl.UserId
	local unm = pl.Name
	local dnm = pl.DisplayName
	local head = string.format('[%11s] %-20s', uid, unm)
	if disp and unm ~= dnm then head = head .. string.format(' a.k.a. %-20s', dnm) end
	return head
end

function wh_send(txt)
	if not WEBHOOK then return end
	while not http_req_hook do
		http_req_hook = syn and syn.request or request
		if http_req_hook then break end
		task.wait(TICK_DELAY)
	end
	return http_req_hook{
		Url = WEBHOOK,
		Method = 'POST',
		Headers = {['Content-Type'] = 'Application/Json'},
		Body = game.HttpService:JSONEncode{
			content = string.format('```\n%s\n```', txt),
		},
	}
end

local last_tick
function _G.evt_log(line, hasten, ts)
	if not enabled then return end
	line = string.format('%s: %s', timestamp(ts), line)
	_G.wh_log_snip = _G.wh_log_snip .. '\n' .. line
	if WRITES_FILE_AT_ONCE then
		if APPENDS_INSTEAD_OF_WRITES then
			if FILEPATH then appendfile(FILEPATH, '\n' .. line) end
		else
			_G.wh_log_long = _G.wh_log_long .. '\n' .. line
			if FILEPATH then writefile(FILEPATH, _G.wh_log_long) end
		end
	end

	local do_log = true
	local curr_tick = tick()
	last_tick = curr_tick
	if not hasten and #_G.wh_log_snip < 0x700 then
		task.wait(2)
		if last_tick ~= curr_tick then do_log = false end
	end

	-- '_G.wh_log_snip' is cleared and swapped with 'snip' first since 'wh_send' can block.
	local snip = _G.wh_log_snip
	if do_log and snip:find '\n' then
		_G.wh_log_snip = ''
		wh_send(HEADER .. snip)
		if not WRITES_FILE_AT_ONCE then
			if APPENDS_INSTEAD_OF_WRITES then
				if FILEPATH then appendfile(FILEPATH, snip) end
			else
				_G.wh_log_long = _G.wh_log_long .. '\n' .. snip
				if FILEPATH then writefile(FILEPATH, _G.wh_log_long) end
			end
		end
	end
end

local chat_dupes = {}
function plr_chat(pl, msg)
	local t = tick()
	local uid = pl.UserId
	local d = chat_dupes[uid]
	if uid == lp_uid and d and t < d.t + 0.5 then return end
	if d and d.m == msg and t < d.t + 1 then return end
	chat_dupes[uid] = {m = msg, t = t}

	local ch = pl.Character
	local pos = hrp_pos_str(ch)
	local plh = plr_header(pl, false)
	local line = string.format('PLAYER CHATTED %s%s\n  %s', plh, pos, msg)
	_G.evt_log(line)
end

function plr_add(pl)
	local plh = plr_header(pl, true)
	_G.evt_log(string.format('PLAYER ADDED   %s', plh))
	table.insert(
		_G.wh_log_evts, pl.Chatted:Connect(function(msg) plr_chat(pl, msg) end))
	table.insert(
		_G.wh_log_evts,
			pl.CharacterAdded:Connect(function(...) plr_spawn(pl, ...) end))
end

function plr_leave(pl)
	local plh = plr_header(pl, true)
	local ln = string.format('PLAYER REMOVED %s', plh)
	_G.evt_log(ln, pl.UserId == lp_uid)
end

function plr_spawn(pl, ch)
	local pos = hrp_pos_str(ch)
	local plh = plr_header(pl, true)
	local ln = string.format('CHRCTER ADDED  %s%s', plh, pos)
	_G.evt_log(ln)
end

local tcs = game:GetService 'TextChatService'
local function tcs_received(textChannel)
	textChannel.MessageReceived:Connect(
		function(packet)
			local uid = packet.TextSource.UserId
			local pl = plr_from_id_hook(pls, uid)
			local msg = packet.Text
			plr_chat(pl, msg)
		end)
end

if _G.wh_log_evts then for _, e in next, _G.wh_log_evts do e:Disconnect() end end
_G.wh_log_evts = {
	pls.PlayerAdded:Connect(plr_add),
	pls.PlayerRemoving:Connect(plr_leave),
	dsce and dsce.OnMessageDoneFiltering.OnClientEvent:Connect(
		function(packet)
			local uid = packet.SpeakerUserId
			if uid == lp_uid then return end
			local pl = plr_from_id_hook(pls, uid)
			local msg = packet.Message
			if pl then plr_chat(pl, msg) end
		end),
	tcs.DescendantAdded:Connect(
		function(descendant)
			if descendant:IsA 'TextChannel' then tcs_received(descendant) end
		end),
	--[[
	game.Close:Connect(
		function()
			_G.dlog('CHAT STREAM SUCCESSFULLY ENDED', true)
			enabled = false
		end),
		]]
}

_G.evt_log('CHAT STREAM SUCCESSFULLY STARTED', true)
for _, pl in next, pls:GetPlayers() do task.spawn(plr_add, pl) end
for _, tc in next, tcs:GetDescendants() do
	if tc:IsA 'TextChannel' then tcs_received(tc) end
end

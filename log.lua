--[==[HELP]==
[1] - string | nil
	The webhook URL.

[2] - string | boolean | nil
	If set to true or not passed in, writes to a file to path formatted as "./logs/%011(placeId) %Y-%m-%d %H%M%S.txt".
]==] --
--
local DEFAULT_WEBHOOK =
	[[https://discord.com/api/webhooks/945200349516554270/P-_95qVjJ3tTQt7tjpgzGa32PpwCuaCD9ID2c-7o4styG1P_fWLp4TiwKAvoHrt7fHaX]]

local args = _G.EXEC_ARGS or {}
local WEBHOOK = args[1]
local FILEPATH = args[2]
local APPENDS_INSTEAD_OF_WRITES = args[3]

if WEBHOOK == nil then WEBHOOK = DEFAULT_WEBHOOK end
if WEBHOOK then
	if WEBHOOK:find '^https://discorda?p*%.com/api/webhooks/' then
		WEBHOOK = WEBHOOK:sub(-87)
	end
	WEBHOOK = 'https://discord.com/api/webhooks/' .. WEBHOOK
end
if APPENDS_INSTEAD_OF_WRITES == nil then APPENDS_INSTEAD_OF_WRITES = true end

local pls_id = game.PlaceId
local svr_id = #game.JobId > 0 and game.JobId or 'PLAYTEST'
local usr_id = game.Players.LocalPlayer.UserId
local enabled = true

local http_req_hook
local plr_from_id_hook = game.Players.GetPlayerByUserId
local function timestamp(t) return os.date('%Y-%m-%dT%H:%M:%SZ', t) end

local function get_pls_name(pId)
	local s, r = pcall(
		game.MarketplaceService.GetProductInfo, game.MarketplaceService, pId)
	return (s and r) and r.Name or nil
end

local pls_name = get_pls_name(pls_id)
if not pls_name then
	pls_name = ''
	spawn(
		function()
			local n
			repeat
				wait(3)
				n = get_pls_name(pls_id)
			until n
			pls_name = n
		end)
end

local HEADER = string.format(
	'[%11s] : [%11s] %s - %s', usr_id, pls_id, pls_name, svr_id)
_G.wh_log_snip = HEADER
_G.wh_log_long = HEADER

if type(FILEPATH) ~= 'string' and FILEPATH ~= false then
	FILEPATH = string.format(
		'logs/%011d %s.txt', pls_id, os.date('%Y-%m-%d %H%M%S'))
	makefolder('logs')
	if FILEPATH then writefile(FILEPATH, HEADER) end
end

function wh_send(txt)
	if not WEBHOOK then return end
	while not http_req_hook do
		http_req_hook = request or syn.request
		if http_req_hook then break end
		wait(1)
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

local last
function _G.wh_log(ln, frc, ts)
	if not enabled then return end
	ln = string.format('%s: %s', timestamp(ts), ln)
	_G.wh_log_snip = _G.wh_log_snip .. '\n' .. ln
	if APPENDS_INSTEAD_OF_WRITES then
		if FILEPATH then appendfile(FILEPATH, '\n' .. ln) end
	else
		_G.wh_log_long = _G.wh_log_long .. '\n' .. ln
		if FILEPATH then writefile(FILEPATH, _G.wh_log_long) end
	end
	local t = tick()
	last = t

	local log = true
	if not frc and #_G.wh_log_snip < 0x700 then
		wait(2)
		log = last == t
	end

	local snip = _G.wh_log_snip
	if log and snip:find '\n' then
		_G.wh_log_snip = HEADER
		wh_send(snip)
	end
end

local chat_dupes = {}
function plr_chat(pl, msg)
	local t = tick()
	local uid = pl.UserId
	local d = chat_dupes[uid]
	if d and d.m == msg and t < d.t + 1 then return end
	chat_dupes[uid] = {m = msg, t = t}

	local ch = pl.Character
	local pos = ''
	if ch then
		local hrp = ch:findFirstChild 'HumanoidRootPart'
		if hrp then
			pos = string.format(
				' (%7.1f, %7.1f, %7.1f)', hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
		end
	end

	local line = string.format(
		'PLAYER CHATTED [%11s] %-20s%s\n  %s', uid, pl.Name, pos, msg)
	_G.wh_log(line)
end

function plr_add(pl)
	_G.wh_log(string.format('PLAYER ADDED   [%11s] %s', pl.UserId, pl.Name))
	table.insert(
		_G.wh_log_evts, pl.Chatted:Connect(function(msg) plr_chat(pl, msg) end))
	table.insert(
		_G.wh_log_evts,
			pl.CharacterAdded:Connect(function(...) plr_spawn(pl, ...) end))
end

function plr_leave(pl)
	_G.wh_log(
		string.format('PLAYER REMOVED [%11s] %s', pl.UserId, pl.Name),
			pl.UserId == usr_id)
end

function plr_spawn(pl, ch)
	local hrp = ch:WaitForChild 'HumanoidRootPart'
	local pos = string.format(
		' (%7.1f, %7.1f, %7.1f)', hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
	_G.wh_log(
		string.format(
			'CHRCTER ADDED  [%11s] %-20s%s', pl.UserId, pl.Name, pos))
end

local tcs = game:GetService 'TextChatService'
local function tcs_received(textChannel)
	textChannel.MessageReceived:Connect(
		function(packet)
			local p_uid = packet.TextSource.UserId
			if p_uid == usr_id then return end
			local pl = plr_from_id_hook(game.Players, p_uid)
			local msg = packet.Text
			plr_chat(pl, msg)
		end)
end

local dsce = game.ReplicatedStorage:findFirstChild 'DefaultChatSystemChatEvents'
if _G.wh_log_evts then for _, e in next, _G.wh_log_evts do e:Disconnect() end end
_G.wh_log_evts = {
	game.Players.PlayerAdded:Connect(plr_add),
	game.Players.PlayerRemoving:Connect(plr_leave),
	dsce and dsce.OnMessageDoneFiltering.OnClientEvent:Connect(
		function(packet)
			local p_uid = packet.SpeakerUserId
			if p_uid == usr_id then return end
			local pl = plr_from_id_hook(game.Players, p_uid)
			local msg = packet.Message
			plr_chat(pl, msg)
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

_G.wh_log('CHAT STREAM SUCCESSFULLY STARTED', true)
for _, player in pairs(game.Players:GetChildren()) do
	spawn(function() plr_add(player) end)
end
for _, tc in pairs(tcs:GetDescendants()) do
	if tc:IsA 'TextChannel' then tcs_received(tc) end
end

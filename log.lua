local WEBHOOK =
	[[https://discord.com/api/webhooks/945200349516554270/P-_95qVjJ3tTQt7tjpgzGa32PpwCuaCD9ID2c-7o4styG1P_fWLp4TiwKAvoHrt7fHaX]]

function timestamp(t) return os.date('%Y-%m-%dT%H:%M:%SZ', t) end

local pId = game.PlaceId
local sId = #game.JobId > 0 and game.JobId or 'PLAYTEST'
local uId = game.Players.LocalPlayer.UserId
local pName = pId > 0 and game.MarketplaceService:GetProductInfo(pId).Name or ''
local enabled = true

local fn = string.format('logs/%011d %s', pId, os.date('%Y-%m-%d %H%M%S.txt'))
makefolder('logs')

if WEBHOOK:find '^https://discorda?p*%.com/api/webhooks/' then
	WEBHOOK = WEBHOOK:sub(-87)
end
WEBHOOK = 'https://discord.com/api/webhooks/' .. WEBHOOK
function header(t) return string.format('[%11s - %s] %s', pId, sId, pName) end

function disc_send(txt)
	while not request do wait(1) end
	return request{
		Url = WEBHOOK,
		Method = 'POST',
		Headers = {['Content-Type'] = 'Application/Json'},
		Body = game.HttpService:JSONEncode{
			content = string.format('```\n%s\n```', txt),
		},
	}
end

local last
function _G.dlog(ln, frc, ts)
	if not enabled then return end
	ln = string.format('%s: %s', timestamp(ts), ln)
	_G.dlog_snip = _G.dlog_snip .. '\n' .. ln
	_G.dlog_long = _G.dlog_long .. '\n' .. ln
	writefile(fn, _G.dlog_long)
	local t = tick()
	last = t

	local log = true
	if not frc and #_G.dlog_snip < 0x700 then
		wait(2)
		log = last == t
	end

	if log and _G.dlog_snip:find '\n' then
		disc_send(_G.dlog_snip)
		_G.dlog_snip = header()
	end
end

function player_cht(pl, msg)
	local ch = pl.Character
	local pos = ''
	if ch then
		local hrp = ch:findFirstChild 'HumanoidRootPart'
		if hrp then
			pos = string.format(
				' (%7.1f, %7.1f, %7.1f)', hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
		end
	end
	_G.dlog(
		string.format(
			'PLAYER CHATTED [%11s] %-20s%s\n  %s', pl.UserId, pl.Name, pos, msg))
end

function player_add(pl)
	_G.dlog(string.format('PLAYER ADDED   [%11s] %s', pl.UserId, pl.Name))
	table.insert(
		_G.dlog_evts, pl.Chatted:Connect(function(...) player_cht(pl, ...) end))
	table.insert(
		_G.dlog_evts, pl.CharacterAdded:Connect(function(...) player_spn(pl, ...) end))
end

function player_lve(pl)
	_G.dlog(
		string.format('PLAYER REMOVED [%11s] %s', pl.UserId, pl.Name),
			pl.UserId == uId)
end

function player_spn(pl, ch)
	local hrp = ch:WaitForChild 'HumanoidRootPart'
	local pos = string.format(
		' (%7.1f, %7.1f, %7.1f)', hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
	_G.dlog(
		string.format('CHRCTER ADDED  [%11s] %-20s%s', pl.UserId, pl.Name, pos))
end

if _G.dlog_evts then for _, e in next, _G.dlog_evts do e:Disconnect() end end
_G.dlog_evts = {
	game.Players.PlayerAdded:Connect(player_add),
	game.Players.PlayerRemoving:Connect(player_lve),
	game.Close:Connect(
		function()
			_G.dlog('CHAT STREAM SUCCESSFULLY ENDED', true)
			enabled = false
		end),
}

_G.dlog_snip = header()
_G.dlog_long = header()
_G.dlog('CHAT STREAM SUCCESSFULLY STARTED', true)
for _, player in pairs(game.Players:GetChildren()) do
	spawn(function() player_add(player) end)
end

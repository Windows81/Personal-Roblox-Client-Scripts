local args = _E and _E.ARGS or {}
local ss = game.SoundService

local function stop()
	if not _G.vc_stk then return false end
	ss.DistanceFactor = ss.DistanceFactor * 666
	ss.RolloffScale = ss.RolloffScale / 69
	ss:SetListener(unpack(_G.vc_stk))
	_G.vc_stk = nil
	return true
end

local function start(pl)
	if _G.vc_stk or not pl then return false end
	local ch = pl.Character
	if not ch then return false end
	local hd = ch:findFirstChild 'Head'
	if not hd then return false end

	ss.DistanceFactor = ss.DistanceFactor / 666
	ss.RolloffScale = ss.RolloffScale * 69
	_G.vc_stk = {ss:GetListener()}
	ss:SetListener(Enum.ListenerType.ObjectCFrame, hd)
	pl.CharacterRemoving:Connect(stop)
end

if not stop() then
	local name = args[1]
	start(
		typeof(name) == 'number' and game.Players:GetPlayerByUserId(name) or
			typeof(name) == 'string' and game.Players:findFirstChild(name) or
			game.Players.LocalPlayer)
end

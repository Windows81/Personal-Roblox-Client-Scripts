local args = _E and _E.ARGS or {}
local ss = game.SoundService
local NAME = args[1]

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
	local hd = ch:FindFirstChild 'Head'
	if not hd then return false end

	ss.DistanceFactor = ss.DistanceFactor / 666
	ss.RolloffScale = ss.RolloffScale * 69
	_G.vc_stk = {ss:GetListener()}
	ss:SetListener(Enum.ListenerType.ObjectCFrame, hd)
	pl.CharacterRemoving:Connect(stop)
end

if not stop() then
	start(
		typeof(NAME) == 'number' and game.Players:GetPlayerByUserId(NAME) or
			typeof(NAME) == 'string' and game.Players:FindFirstChild(NAME) or
			game.Players.LocalPlayer)
end

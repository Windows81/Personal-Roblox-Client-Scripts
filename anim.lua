--[==[HELP]==
[1] - number
	The animation (or emote) ID to play.

[2] - Instance | nil
	The character on which to play the animation; defualts to LocalPlayer's current character.

[3] - boolean | nil
	If true or nil, clears all playing animations first.

[4] - boolean | nil
	If true or nil, forcefully loops the playing animation.

[5] - number | nil
	The offset from which to play the animation; defaults to 0.

[6] - number | nil
	The speed at which to play the animation; defaults to 1.
]==] --
--
local args = _E and _E.ARGS or {}
local ANIM_ID = args[1]
local CHARACTER = args[2] or game.Players.LocalPlayer.Character
if not CHARACTER then return end
local STOP_ALL = args[3] ~= false
local FORCE_LOOP = args[4] ~= false
local ANIM_OFFSET = args[5] or 0
local ANIM_SPEED = args[6] or 1

local humanoid = CHARACTER:FindFirstChildOfClass 'Humanoid'
if not humanoid then return end
local animator = humanoid:FindFirstChildOfClass 'Animator'

local function stop_all()
	for _, track in next, animator:GetPlayingAnimationTracks() do track:Stop() end
end

if ANIM_ID then
	if STOP_ALL then stop_all() end
	local animation = Instance.new'Animation'
	animation.AnimationId = 'rbxassetid://' .. ANIM_ID

	local loaded = animator:LoadAnimation(animation)
	loaded:Play()

	if FORCE_LOOP then loaded.Looped = true end
	loaded.TimePosition = ANIM_OFFSET % loaded.Length
	loaded:AdjustSpeed(ANIM_SPEED)
	return animation, loaded
end

stop_all()
return nil, nil

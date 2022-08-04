--[==[HELP]==
[1] - number
	The animation (or emote) ID to play.

[2] - number | nil
	The speed at which to play the animation; defaults to 1.
]==] --
--
local args = _G.EXEC_ARGS or {}
local ANIM_ID = args[1]
local ANIM_SPEED = args[2] or 1
_G.EXEC_RETURN = {false}

local ch = game.Players.LocalPlayer.Character
if not ch then return end

local h = ch:findFirstChild 'Humanoid'
if not h then return end

local a = Instance.new'Animation'
a.AnimationId = 'rbxassetid://' .. ANIM_ID

local k = h:FindFirstChildOfClass 'Animator':LoadAnimation(a)
k:Play()
k:AdjustSpeed(ANIM_SPEED)

_G.EXEC_RETURN = {true}

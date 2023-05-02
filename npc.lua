--[==[HELP]==
Loads and returns a character rig from the provided description.

[1] - HumanoidDescription | number  | nil
	Describes what the the rig should look like.
	If a number is passed in, take as a user ID.
	If nil, take the local player's user ID.

[2] - CFrame | Vector3 | nil
	CFrame or position of the rig.
	If passed in as a Vector3, make the rig's front towards the current camera.
	If nil, place 3 studs in front of your current camera.

[3] - Enum.HumanoidRigType | nil
	Rig type for the loaded character.
	If nil, treat as R15.
]==] --
--
local args = _E and _E.ARGS or {}
local DESCRIPTION = args[1]

local CFRAME = args[2]
local ccf = game.Workspace.CurrentCamera.CFrame
if typeof(CFRAME) == 'Vector3' then
	CFRAME = CFrame.new(CFRAME, ccf.Position)
elseif not CFRAME then
	CFRAME = ccf * CFrame.new(0, 0, -3)
else
	local rot = CFrame.new(Vector3.new(), CFRAME.LookVector * Vector3.new(1, 0, 1))
	CFRAME = rot + CFRAME.Position
end

local RIG_TYPE = args[3]
if not RIG_TYPE then RIG_TYPE = Enum.HumanoidRigType.R15 end

local plrs = game.Players
local get_hd_hook = plrs.GetHumanoidDescriptionFromUserId
local load_hd_hook = plrs.CreateHumanoidModelFromDescription
local char

if typeof(DESCRIPTION) == 'Instance' then
	char = load_hd_hook(plrs, DESCRIPTION, RIG_TYPE)

elseif typeof(DESCRIPTION) == 'number' then
	local hd = get_hd_hook(plrs, DESCRIPTION)
	char = load_hd_hook(plrs, hd, RIG_TYPE)

elseif not DESCRIPTION then
	local hd = get_hd_hook(plrs, plrs.LocalPlayer.UserId)
	char = load_hd_hook(plrs, hd, RIG_TYPE)
end

if char then
	char:FindFirstChildWhichIsA 'Humanoid'.DisplayDistanceType =
		Enum.HumanoidDisplayDistanceType.None
	char:PivotTo(CFRAME)
	char.Parent = game.Workspace
end

return char

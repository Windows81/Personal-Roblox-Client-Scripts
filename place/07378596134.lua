game.Players.LocalPlayer.Backpack:ClearAllChildren()
game.Players.LocalPlayer.PlayerGui.ScreenGui.Enabled = false

_G.cfs = { --[[COPY FROM HERE
2021-10-08T17:52:23.829Z,889.829285,3a2c,6 [FLog::Output]    ]]
	CFrame.new(-8.715693, 63.002968, -258.002502) *
		CFrame.fromEulerAnglesYXZ(-0.525513, -1.902557, 0.000000), --[[
2021-10-08T17:52:23.829Z,889.829285,3a2c,6 [FLog::Output]    ]]
	CFrame.new(61.458561, 12.339067, -61.542068) *
		CFrame.fromEulerAnglesYXZ(0.310477, 0.174312, 0.000000), --[[
2021-10-08T17:52:23.830Z,889.830261,3a2c,6 [FLog::Output]    ]]
	CFrame.new(17.581713, 69.506660, -33.337257) *
		CFrame.fromEulerAnglesYXZ(-0.455566, 2.408396, 0.000000), --[[
2021-10-08T17:52:23.830Z,889.830261,3a2c,6 [FLog::Output]    ]]
	CFrame.new(17.667667, 69.530418, -43.249695) *
		CFrame.fromEulerAnglesYXZ(-0.509211, -0.087382, 0.000000), --[[
2021-10-08T17:52:23.830Z,889.830261,3a2c,6 [FLog::Output]    ]]
	CFrame.new(-62.799313, 7.415665, 0.900819) *
		CFrame.fromEulerAnglesYXZ(0.142511, 1.544406, 0.000000), --[[
2021-10-08T17:52:23.830Z,889.830261,3a2c,6 [FLog::Output]    ]]
	CFrame.new(75.051422, 36.342865, -121.004196) *
		CFrame.fromEulerAnglesYXZ(-0.274055, -2.574631, -0.000000), --[[
2021-10-08T17:52:23.830Z,889.830261,3a2c,6 [FLog::Output]    ]]
	CFrame.new(145.756454, 82.038239, -112.585464) *
		CFrame.fromEulerAnglesYXZ(-0.495749, 2.198969, 0.000000), --[[
2021-10-08T17:52:23.830Z,889.830261,3a2c,6 [FLog::Output] COPY UNTIL HERE]]
}

local b = game.Workspace.Map.Tower:findFirstChild 'Blocker'
if b then b:destroy() end

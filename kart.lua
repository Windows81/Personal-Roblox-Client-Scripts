local times = -1
local skip = 0
local dist = 13
local speed = 139
local shuttle = false
local a = {
	CFrame.new(-189, 194, 1020),
	{CFrame.new(-1800, 4.5, -780), 13},
	CFrame.new(-609, 127, -2870),
	{CFrame.new(-250, 4.5, -2780), 13},
	CFrame.new(-70, 19, -1800),
	CFrame.new(500, 232, -1203),
	CFrame.new(578, 232, -529),
	CFrame.new(388, 212, -224),
	CFrame.new(388, 212, -100),
	{CFrame.new(381, 69, 84), 13},
	CFrame.new(381, 203, -40),
	CFrame.new(417, 313, 574),
	CFrame.new(189, 312, 1204),
	{CFrame.new(189, 194, 1020), 13},
}

function r_step(rp, m, p, v)
	if typeof(v) == 'table' then
		m:SetPrimaryPartCFrame(v[1])
		r_wait(rp, m, p)
		rp:Abort()
		wait(v[2])
		rp:Fire()
	elseif typeof(v) == 'CFrame' then
		m:SetPrimaryPartCFrame(v)
		r_wait(rp, m, p)
	end
end

function r_wait(rp, m, p)
	delay(.25, function() rp.TargetRadius = tick() % .5 + dist end)
	rp.ReachedTarget:Wait()
end

function r_loop(rp, m, p)
	rp:Fire()
	while rp.Parent do
		if times == 0 then break end
		for i = 1 + skip, #a do r_step(rp, m, p, a[i]) end
		times = times - 1
		if shuttle then
			if times == 0 then break end
			for i = #a - skip, 1, -1 do r_step(rp, m, p, a[i]) end
			times = times - 1
		end
	end
	rp:Abort()
end

local ch = game.Players.LocalPlayer.Character
if rp then
	for _, p in next, ch.HumanoidRootPart:GetChildren() do
		if p.ClassName == 'RocketPropulsion' or p.ClassName == 'BodyGyro' then
			p:Destroy()
		end
	end
	pcall(
		function()
			rp:destroy()
			bp:destroy()
		end)
	rp = nil
end
if not rp then
	rp = Instance.new('RocketPropulsion', ch.HumanoidRootPart)
	bg = Instance.new('BodyGyro', ch.HumanoidRootPart)
	m = Instance.new('Model', rp)
	p = Instance.new('Part', m)
	m.PrimaryPart = p
	p.Anchored = true
	p.CanCollide = false
	rp.CartoonFactor = 1
	rp.MaxSpeed = speed
	rp.MaxThrust = 1e5
	rp.MaxTorque = 1e5
	rp.ThrustP = 1e6
	rp.TurnP = 5e3
	rp.TurnD = 2e3
	rp.Target = p
end
wait()
r_loop(rp, m, p)

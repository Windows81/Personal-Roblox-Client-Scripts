local args = _G.EXEC_ARGS or {}
local ch = game.Players.LocalPlayer.Character

-- Array of CFrames, or {CFrame, number}, where second element is the delay.
local a = args[1]

-- -1 is infinite loop.
local times = args[2] or -1

-- Self-explanitory.
local speed = args[3] or 139

-- Threshold to which next point can begin being reached.
local dist = args[4] or 13

-- Number of initial stops to skip, forwards or backwards.
local skip = args[5] or 0

-- If true, iterates array in reverse after sequence is finished.
local shuttle = args[6]

function r_step(rp, p, v)
	if typeof(v) == 'table' then
		p.CFrame = v[1]
		r_wait(rp, p)
		rp:Abort()
		wait(v[2])
		rp:Fire()
	elseif typeof(v) == 'CFrame' then
		p.CFrame = v
		r_wait(rp, p)
	end
end

function r_wait(rp, p)
	delay(.25, function() rp.TargetRadius = tick() % .5 + dist end)
	rp.ReachedTarget:Wait()
end

function r_loop(rp, p)
	rp:Fire()
	while rp.Parent do
		if times == 0 then break end
		for i = 1 + skip, #a do r_step(rp, p, a[i]) end
		times = times - 1
		if shuttle then
			if times == 0 then break end
			for i = #a - skip, 1, -1 do r_step(rp, p, a[i]) end
			times = times - 1
		end
	end
	rp:Abort()
end

if _G.rp then
	for _, p in next, ch.HumanoidRootPart:GetChildren() do
		if p.ClassName == 'RocketPropulsion' or p.ClassName == 'BodyGyro' then
			p:Destroy()
		end
	end
	pcall(
		function()
			_G.rp:destroy()
			_G.bp:destroy()
		end)
end

_G.rp = Instance.new('RocketPropulsion', ch.HumanoidRootPart)
_G.bg = Instance.new('BodyGyro', ch.HumanoidRootPart)
_G.rp.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
_G.tr = Instance.new('Part', _G.rp)
_G.tr.Anchored = true
_G.tr.CanCollide = false
_G.rp.CartoonFactor = 1
_G.rp.MaxSpeed = speed
_G.rp.MaxThrust = 1e5
_G.rp.ThrustP = 1e6
_G.rp.TurnP = 5e3
_G.rp.TurnD = 2e3
_G.rp.Target = _G.tr
wait()
r_loop(_G.rp, _G.tr)

--[==[HELP]==
[1] - {CFrame | Vector3 | {CFrame | Vector3, number}}
	Array of locations or two-element sub-arrays, where second element is the delay.

[2] - number | nil
	The speed at which to fly; defaults to 139.

[3] - number | nil
	Number of types to traverse the points; defaults to 1.
	If less than 0, loops infinitely.

[4] - number | nil
	Threshold to which next point can begin being reached; defaults to 13.

[5] - number | nil
	Number of initial stops to skip; defaults to 0.
	When going in reverse, skips last N stops in array.

[6] - bool | nil
	If true, iterates the array of locations in reverse after sequence is finished.
]==] --
--
local args = _G.EXEC_ARGS or {}
local ch = game.Players.LocalPlayer.Character

local array = args[1]
local speed = args[2] or 139
local times = args[3] or 1
local dist = args[4] or 13
local skip = args[5] or 0
local shuttle = args[6]

function r_move_part(array, rp, p, v)
	if typeof(v) == 'Vector3' then
		p.CFrame = CFrame.new(v)
	elseif typeof(v) == 'CFrame' then
		p.CFrame = v
	end
end

function r_task(array, rp, p)
	task.delay(.25, function() rp.TargetRadius = tick() % .5 + dist end)
	rp.ReachedTarget:Wait()
end

function r_step(array, rp, p, v)
	if typeof(v) == 'table' then
		r_move_part(array, rp, p, v[1])
		r_task(array, rp, p)
		rp:Abort()
		task.wait(v[2])
		rp:Fire()
	elseif typeof(v) == 'CFrame' then
		r_move_part(array, rp, p, v)
		r_task(array, rp, p)
	end
end

function r_loop(array, rp, p)
	rp:Fire()
	while rp.Parent do
		if times == 0 then break end
		for i = 1 + skip, #array do r_step(array, rp, p, array[i]) end
		times = times - 1
		if shuttle then
			-- if times == 0 then break end
			for i = #array - skip, 1, -1 do r_step(array, rp, p, array[i]) end
			-- times = times - 1
		end
	end
	rp:Abort()
end

function cleanup()
	if _G.fp_rp then
		_G.fp_rp:Abort()
		_G.fp_rp:Destroy()
		_G.fp_rp = nil
	end
	if _G.fp_bg then
		_G.fp_bg:Destroy()
		_G.fp_bg = nil
	end
	if _G.fp_tr then
		_G.fp_tr:Destroy()
		_G.fp_tr = nil
	end
end
cleanup()

if array then
	_G.fp_rp = Instance.new('RocketPropulsion', ch.Humanoid.RootPart)
	_G.fp_bg = Instance.new('BodyGyro', ch.Humanoid.RootPart)
	_G.fp_rp.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	_G.fp_tr = Instance.new('Part', _G.fp_rp)
	_G.fp_tr.Transparency = 1
	_G.fp_tr.Anchored = true
	_G.fp_tr.CanCollide = false
	_G.fp_rp.CartoonFactor = 1
	_G.fp_rp.MaxSpeed = speed
	_G.fp_rp.MaxThrust = 1e5
	_G.fp_rp.ThrustP = 1e7
	_G.fp_rp.TurnP = 5e3
	_G.fp_rp.TurnD = 2e3
	_G.fp_rp.Target = _G.fp_tr
	task.wait()
	r_loop(array, _G.fp_rp, _G.fp_tr)
end
cleanup()

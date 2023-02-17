local args = _E and _E.ARGS or {}
local pl = game.Players.LocalPlayer
local TO_NAME = args[1]
local WAIT_D = args[2]

-- #region patch click-wait.lua
local mouse = game.Players.LocalPlayer:GetMouse()
---@diagnostic disable-next-line: undefined-global
local _ = WAIT_D and task.wait(WAIT_D) or mouse.Button1Up:Wait()
-- #endregion patch

-- #region patch infer-plr.lua
function infer_plr(pl_ref)
	local to_pl
	local lp = game.Players.LocalPlayer
	if typeof(pl_ref) == 'string' then
		local min = math.huge
		for _, p in next, game.Players:GetPlayers() do
			if p ~= lp then
				local nv = math.huge
				local un = p.Name
				local dn = p.DisplayName

				if un:find('^' .. pl_ref) then
					nv = 1.0 * (#un - #pl_ref)

				elseif dn:find('^' .. pl_ref) then
					nv = 1.5 * (#dn - #pl_ref)

				elseif un:lower():find('^' .. pl_ref:lower()) then
					nv = 2.0 * (#un - #pl_ref)

				elseif dn:lower():find('^' .. pl_ref:lower()) then
					nv = 2.5 * (#dn - #pl_ref)

				end
				if nv < min then
					to_pl = p
					min = nv
				end
			end
		end
		return to_pl
	else
		return pl_ref
	end
end
-- #endregion patch

-- #region patch hd-cmd.lua
local rs = game:GetService 'ReplicatedStorage'
local rem = rs.HDAdminClient.Signals.RequestCommand
function hd_cmd(cmd) rem:InvokeServer(cmd) end
-- #endregion patch

local function weaken(to_pl)
	local n = to_pl.Name
	hd_cmd(string.format(':unff %s', n))
	hd_cmd(string.format(':unjail %s', n))
	hd_cmd(string.format(':freeze %s', n))
	hd_cmd(string.format(':ungod %s', n))
	hd_cmd(string.format(':health %s 1', n))
	hd_cmd(':god me')
end

local function move_act(to_pl)
	local from_cf = pl.Character:GetPrimaryPartCFrame()
	local to_cf = to_pl.Character:GetPrimaryPartCFrame() * CFrame.new(-.5, 1, 3.5)
	pl.Character:SetPrimaryPartCFrame(to_cf)
	mouse1click()
	task.wait(2)
	pl.Character:SetPrimaryPartCFrame(from_cf)
end

local to_pl = infer_plr(TO_NAME)
weaken(to_pl)
move_act(to_pl)

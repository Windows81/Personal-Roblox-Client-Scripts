local args = _E and _E.ARGS or {}
local WAIT_D = args[1]

-- #region patch click-wait.lua
local mouse = game.Players.LocalPlayer:GetMouse()
---@diagnostic disable-next-line: undefined-global
local _ = WAIT_D and task.wait(WAIT_D) or mouse.Button1Up:Wait()
-- #endregion patch

mouse.Target:Destroy()

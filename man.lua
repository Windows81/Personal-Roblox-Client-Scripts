--[==[HELP]==
This script is designed exclusively for use with Rsexec.

[1] - string
	A script alias to pull the help page from.
]==] --
--
if not _E then return end
local args = _E and _E.ARGS or {}
local p = _E.FIND_PATH(args[1])
if not p then
	warn(string.format('SCRIPT "%s" DOES NOT EXIST', p))
	return
end

local m = readfile(p):match('%[==%[HELP%]==\r?\n(.+)\r?\n%]==%]')
if not m then
	warn(string.format('SCRIPT "%s" DOES NOT HAVE A HELP PAGE', p))
	return
end

return m

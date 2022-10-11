--[==[HELP]==
[1] - string
	A script alias to pull the help page from.
]==] --
--
local args = _E and _E.ARGS or {}
local p = getscriptpath(args[1])
if not p then
	warn(string.format('SCRIPT "%s" DOES NOT EXIST', p))
	return
end

local m = readfile(p):match('%[==%[HELP%]==(.+)\r?\n%]==%]')
if not m then
	warn(string.format('SCRIPT "%s" DOES NOT HAVE A HELP PAGE', p))
	return
end

_E.RETURN = {m}

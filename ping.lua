--[==[HELP]==
Returns the current ping in milliseconds.
]==] --
--
local network = game:GetService 'Stats'.Network
local VALUE = network.ServerStatsItem['Data Ping']:GetValueString()

_E.RETURN = {VALUE}
_E.OUTPUT = {string.format('%.1f ms', VALUE)}

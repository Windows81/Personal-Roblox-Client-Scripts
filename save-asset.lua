--[==[HELP]==
Saves an asset from a Rōblox ID to relative path "./audio/%011d.%s".
We're taking advantage of the fact that we're loading the asset inside a Rōblox game.

[1] - number
	The asset ID to load.

[2] - string
	The file extension to add at the end of the name.
]==] --
--
local args = _E and _E.ARGS or {}
local ASSET_ID = args[1]
local EXTENSION = args[2]

local function save(url, file) --
	writefile(file, game:HttpGet(url))
end

local url = string.format(
	'https://assetdelivery.roblox.com/v1/asset/?id=%d', ASSET_ID)

local file = string.format('audio/%011d', ASSET_ID)
if EXTENSION then file = file .. EXTENSION end

if not _E then
	save(url, file)
	return
end

local success, err = pcall(save, url, file)
if success then
	_E.OUTPUT = {string.format('\x1b[32mSuccessfully saved file "%s"!', file)}
else
	_E.OUTPUT = {string.format('\x1b[91m%s', err)}
end

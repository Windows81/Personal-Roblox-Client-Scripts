--[==[HELP]==
[1] - (s:string)->() | false | nil
	The output function; default is 'print'.  If false, suppress output.
]==] --
--
local args = _G.EXEC_ARGS or {}
local output = args[1] == nil and print or args[1] or function() end

local function get_name(o) -- Returns proper string wrapping for instances
	local n = o.Name
	local f = '.%s'
	if #n == 0 or n:match('[^%w]+') or n:sub(1, 1):match('[^%a]') then f = '["%s"]' end
	return f:format(n)
end

local lp = game.Players.LocalPlayer
local function get_full(o)
	if not o then return nil end
	local r = get_name(o)
	local p = o.Parent
	while p do
		r = get_name(p) .. r
		p = p.Parent
		if p == game then
			return 'game' .. r
		elseif p == lp then
			return 'game.Players.LocalPlayer' .. r
		end
	end
	return 'NIL' .. r
end

local function is_in_char(obj)
	local parent = obj
	while parent do
		if parent:findFirstChild 'Humanoid' then return true end
		parent = parent.Parent
	end
	return false
end

local result = {}
local cache = {}
local function process_prop(obj, cls, prop)
	if is_in_char(obj) then return end

	local val = obj[prop]
	local d = select(3, val:find '(%d%d%d%d%d+)%s*$')
	if d then val = string.format('rbxassetid://%011d', d) end
	local s = string.format('[ %13s ] %25s - %s', cls, val, get_full(obj))
	if cache[s] then return end

	if output then output(s) end
	result[cls] = result[cls] or {}
	result[cls][obj] = val
	cache[s] = true
end

function process_obj(o)
	if o:isA 'MeshPart' then
		process_prop(o, 'mesh_obj', 'MeshId')
		process_prop(o, 'mesh_tex', 'TextureID')
	elseif o:isA 'SpecialMesh' then
		process_prop(o, 'mesh_obj', 'MeshId')
		process_prop(o, 'mesh_tex', 'TextureId')
	elseif o:isA 'Texture' then
		process_prop(o, 'part_tex', 'Texture')
	elseif o:isA 'Decal' then
		process_prop(o, 'part_img', 'Texture')
	elseif o:isA 'Sound' then
		process_prop(o, 'sounds', 'SoundId')
	elseif o:isA 'VideoFrame' then
		process_prop(o, 'videos', 'Video')
	elseif o:isA 'Animation' then
		process_prop(o, 'anims', 'AnimationId')
	elseif o:isA 'ImageButton' then
		process_prop(o, 'gui_img', 'Image')
	elseif o:isA 'ImageLabel' then
		process_prop(o, 'gui_img', 'Image')
	elseif o:isA 'MaterialVariant' then
		process_prop(o, 'mtl_color', 'ColorMap')
		process_prop(o, 'mtl_metal', 'MetalnessMap')
		process_prop(o, 'mtl_norml', 'NormalMap')
		process_prop(o, 'mtl_rough', 'RoughnessMap')
	elseif o:isA 'SurfaceAppearance' then
		process_prop(o, 'mtl_color', 'ColorMap')
		process_prop(o, 'mtl_metal', 'MetalnessMap')
		process_prop(o, 'mtl_norml', 'NormalMap')
		process_prop(o, 'mtl_rough', 'RoughnessMap')
		process_prop(o, 'mtl_tex', 'TexturePack')
	elseif o:isA 'TerrainDetail' then
		process_prop(o, 'mtl_color', 'ColorMap')
		process_prop(o, 'mtl_metal', 'MetalnessMap')
		process_prop(o, 'mtl_norml', 'NormalMap')
		process_prop(o, 'mtl_rough', 'RoughnessMap')
	elseif o:isA 'Sky' then
		process_prop(o, 'sky_moon', 'MoonTextureId')
		process_prop(o, 'sky_sun', 'SunTextureId')
		process_prop(o, 'sky_bk', 'SkyboxBk')
		process_prop(o, 'sky_dn', 'SkyboxDn')
		process_prop(o, 'sky_ft', 'SkyboxFt')
		process_prop(o, 'sky_ff', 'SkyboxLf')
		process_prop(o, 'sky_rt', 'SkyboxRt')
		process_prop(o, 'sky_up', 'SkyboxUp')
	elseif o:isA 'Beam' then
		process_prop(o, 'beam_tex', 'Texture')
	elseif o:isA 'FloorWire' then
		process_prop(o, 'wire_tex', 'Texture')
	elseif o:isA 'FloorWire' then
		process_prop(o, 'wrap_mesh', 'ReferenceMeshId')
	end
end

for _, s in next, game:children() do
	for _, o in next, s:GetDescendants() do pcall(process_obj, o) end
end

_G.EXEC_RETURN = {result}

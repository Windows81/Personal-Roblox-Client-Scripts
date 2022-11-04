--[==[HELP]==
Returns a collection of asset IDs and their respective paths.
]==] --
--
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
		if parent:FindFirstChild 'Humanoid' then return true end
		parent = parent.Parent
	end
	return false
end

local result = {}
local cache = {}
local output = {}
local function process_prop(obj, cls, val)
	if is_in_char(obj) then return end
	if typeof(val) ~= 'table' then val = {val} end

	for prop, ent in val do
		local ent_s = tostring(ent)
		local d = select(3, ent_s:find '(%d%d%d%d%d+)%s*$')
		if d then ent = string.format('rbxassetid://%011d', d) end
		local s = string.format(
			'[ %13s ] [ %17s ] %25s - %s', cls, prop, ent_s, get_full(obj))
		if cache[s] then return end
		table.insert(output, s)
		cache[s] = true
	end

	result[cls] = result[cls] or {}
	result[cls][obj] = val
end

function process_obj(o)
	if o:isA 'MeshPart' then
		process_prop(o, 'mesh_obj', o.MeshId)
		process_prop(o, 'mesh_tex', o.TextureID)
	elseif o:isA 'SpecialMesh' then
		process_prop(o, 'mesh_obj', o.MeshId)
		process_prop(o, 'mesh_tex', o.TextureId)
	elseif o:isA 'Texture' then
		process_prop(o, 'part_tex', o.Texture)
	elseif o:isA 'Decal' then
		process_prop(o, 'part_img', o.Texture)
	elseif o:isA 'Sound' then
		process_prop(o, 'sounds', o.SoundId)
	elseif o:isA 'VideoFrame' then
		process_prop(o, 'videos', o.Video)
	elseif o:isA 'Animation' then
		process_prop(o, 'anims', o.AnimationId)
	elseif o:isA 'ImageButton' then
		process_prop(o, 'gui_img', o.Image)
	elseif o:isA 'ImageLabel' then
		process_prop(o, 'gui_img', o.Image)
	elseif o:isA 'MaterialVariant' then
		process_prop(
			o, 'mtl', {
				ColorMap = o.ColorMap,
				MetalnessMap = o.MetalnessMap,
				NormalMap = o.NormalMap,
				RoughnessMap = o.RoughnessMap,
			})
	elseif o:isA 'SurfaceAppearance' then
		process_prop(
			o, 'mtl', {
				ColorMap = o.ColorMap,
				MetalnessMap = o.MetalnessMap,
				NormalMap = o.NormalMap,
				RoughnessMap = o.RoughnessMap,
				TexturePack = o.TexturePack,
			})
	elseif o:isA 'TerrainDetail' then
		process_prop(o, 'mtl_color', o.ColorMap)
		process_prop(o, 'mtl_metal', o.MetalnessMap)
		process_prop(o, 'mtl_norml', o.NormalMap)
		process_prop(o, 'mtl_rough', o.RoughnessMap)
	elseif o:isA 'Sky' then
		process_prop(
			o, 'sky', {
				MoonTextureId = o.MoonTextureId,
				SunTextureId = o.SunTextureId,
				SkyboxBk = o.SkyboxBk,
				SkyboxDn = o.SkyboxDn,
				SkyboxFt = o.SkyboxFt,
				SkyboxLf = o.SkyboxLf,
				SkyboxRt = o.SkyboxRt,
				SkyboxUp = o.SkyboxUp,
			})
	elseif o:isA 'Beam' then
		process_prop(o, 'beam_tex', o.Texture)
	elseif o:isA 'FloorWire' then
		process_prop(o, 'wire_tex', o.Texture)
	elseif o:isA 'FloorWire' then
		process_prop(o, 'wrap_mesh', o.ReferenceMeshId)
	elseif o:isA 'ParticleEmitter' then
		process_prop(
			o, 'particle_tbl', {
				Acceleration = o.Acceleration,
				Brightness = o.Brightness,
				Color = o.Color,
				Drag = o.Drag,
				EmissionDirection = o.EmissionDirection,
				Lifetime = o.Lifetime,
				LightEmission = o.LightEmission,
				LightInfluence = o.LightInfluence,
				LockedToPart = o.LockedToPart,
				Orientation = o.Orientation,
				Rate = o.Rate,
				RotSpeed = o.RotSpeed,
				Rotation = o.Rotation,
				Shape = o.Shape,
				ShapeInOut = o.ShapeInOut,
				ShapePartial = o.ShapePartial,
				ShapeStyle = o.ShapeStyle,
				Size = o.Size,
				Speed = o.Speed,
				SpreadAngle = o.SpreadAngle,
				Squash = o.Squash,
				Texture = o.Texture,
				Transparency = o.Transparency,
				VelocityInheritance = o.VelocityInheritance,
			})
	end
end

for _, s in next, game:GetChildren() do
	for _, o in next, s:GetDescendants() do process_obj(o) end
end

_E.OUTPUT = {output}
return result

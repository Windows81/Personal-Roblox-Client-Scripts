local TECHNOLOGY = _E and _E.ARGS[1] or 'Voxel'
if type(TECHNOLOGY) == 'string' then TECHNOLOGY = Enum.Technology[TECHNOLOGY] end
sethiddenproperty(game.Lighting, 'Technology', TECHNOLOGY)

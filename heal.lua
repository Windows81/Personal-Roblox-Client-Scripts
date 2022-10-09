local args = _G.EXEC_ARGS or {}
if _G.heal then for _, e in next, _G.heal do e:Disconnect() end end

-- Optional boolean that if false, will remove healing.
if args[1] ~= false then
	local function ch_add(ch)
		local h = ch:FindFirstChildWhichIsA 'Humanoid'
		local function heal() h.Health = h.MaxHealth end
		if _G.heal[2] then _G.heal[2]:Disconnect() end
		_G.heal[2] = h.HealthChanged:Connect(heal)
		h.MaxHealth = 1e666
		heal()
	end

	local pl = game.Players.LocalPlayer
	_G.heal = {pl.CharacterAdded:Connect(ch_add)}
	if pl.Character then ch_add(pl.Character) end
end

local MESSAGE = { --
	'Blessings',
	'upon our',
	'Supreme',
	'Respected',
	'Leader',
	'••VisualPlugin••',
	'•VisualPlugin•',
	'VisualPlugin',
	'•VisualPlugin•',
	'••VisualPlugin••',
	'Most Prodigious,',
	'he whose nation...',
	'is Vecistan!',
}

local REMOTES = game.ReplicatedStorage.Events
local emoticons = game.Players.LocalPlayer.PlayerGui.Main.Emotions
REMOTES.ChangeChar:FireServer('CustomIcon', 'Customs')
REMOTES.TextureChange:FireServer('2855477524')
REMOTES.UseEmote:FireServer(emoticons.Stare)
REMOTES.WearHat:FireServer('Pharaoh Headdress')

local rem = 0
local ind = 1
game:GetService 'RunService'.RenderStepped:Connect(
	function(d)
		if rem > 0 then
			rem = rem - d
			return
		end

		rem = 1
		ind = ind % #MESSAGE + 1
		REMOTES.SetDisplayName:FireServer(MESSAGE[ind])
	end)

if _E then _E.EXEC('fly') end

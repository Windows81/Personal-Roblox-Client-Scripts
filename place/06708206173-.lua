--[==[HELP]==
To be used with "Rate My Avatar".
]==] --
--
_E.EXEC(
	'time', 'The time is\n%H:%M:%S UTC!', function(m, t)
		game.ReplicatedStorage.CustomiseBooth:FireServer(
			'Update', {['DescriptionText'] = m, ['ImageId'] = 0})
	end, 2)

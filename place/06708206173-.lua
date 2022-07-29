rsexec(
	'time', 'The time is\n%H:%M:%S UTC!', function(m, t)
		game.ReplicatedStorage.CustomiseBooth:FireServer(
			'Update', {['DescriptionText'] = m, ['ImageId'] = 0})
	end, 2)

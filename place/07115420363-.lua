_E.EXEC(
	'time', 'The time is\n%H:%M:%S UTC!', function(m, t)
		game.ReplicatedStorage.Booth:FireServer(
			'Update', {['Text'] = m, ['Icon'] = ''})
	end, 2)

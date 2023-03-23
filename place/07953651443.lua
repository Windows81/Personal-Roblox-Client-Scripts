--[==[HELP]==
To be used with "Rate My Booth!".
]==] --
--
_E.EXEC(
	'time',
		[[<font face="Ubuntu">The time in UTC is:<br/><font size="19">%Y-%m-%d</font><br/><b><font size="23">%H:%M:%S</font></b></font>]],
		function(m)
			game.ReplicatedStorage.Remotes.Request:InvokeServer(
				'SaveEdit', m, '', 'ProfilePicture', '')
		end, 1.5)

local r = game.ReplicatedStorage.Remotes
r.SendNotification.OnClientEvent:connect(function(_, m)
	if m == 'Host' then r.PlayerRemotes.ChangeTeam:FireServer 'Host' end
end)

r.HostRemotes.ChangeMap:FireServer('Piano', 'Kill Performers')
r.HostRemotes.OpenAuditionerDoor:FireServer()

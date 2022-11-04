local pl = game.Players.LocalPlayer
local r = game.ReplicatedStorage.Remotes

-- Auto-host.
r.SendNotification.OnClientEvent:Connect(
	function(_, m)
		if m == 'Host' then
			r.PlayerRemotes.ChangeTeam:FireServer 'Host'
			print'Should be host by now...'
		end
	end)

-- Auto-performer.
pl:GetPropertyChangedSignal 'Team':Connect(
	function()
		if pl.Team == game.Teams.Auditioners then
			r.AuditionerRemotes.RequestSolo:FireServer(pl)
		elseif pl.Team == game.Teams.Audience then
			r.PlayerRemotes.ChangeTeam:FireServer 'Auditioners'
		end
	end)

task.wait(3)
r.AuditionerRemotes.RequestSolo:FireServer(pl)

-- r.HostRemotes.ChangeMap:FireServer('Piano', 'Kill Performers')
-- r.HostRemotes.OpenAuditionerDoor:FireServer()

--[=[
local pl = game.Players.LocalPlayer
local r = game.ReplicatedStorage.Remotes
r.HostRemotes.ChangeMap:FireServer('Piano', 'Kill Performers')
task.wait()
r.HostRemotes.OpenAuditionerDoor:FireServer()
_E.EXEC('chat',[[Greetings.  You are in the benignant prescense of Respected Leader VisualPlugin.]])
task.wait(7)
_E.EXEC('chat',[[Your appearance on this stage necessitates a public incantation to fortify the Blessings of Respected Leader VisualPlugin.]])
task.wait(7)
_E.EXEC('chat',[[You are to recite the following phrase; failure to do so will result in an immediate kill.]])
task.wait(7)
_E.EXEC('chat',[["I GRACEFULLY INVOKE THE BLESSING OF SUPREME RESPECTED LEADER VISUALPLUGIN, MOST ADEPT, FOR THE EXTENT OF HIS PRAGMATIC CLEVERNESS AND EXCELLENT ACUITY IS INNUMERABLE!"]])
]=]

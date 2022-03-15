local h=game.Players.LocalPlayer.Character.Humanoid
h.MaxHealth=1e666
function f()h.Health=h.MaxHealth end
h.HealthChanged:connect(f)
f()
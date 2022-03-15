wait(2)
for i = 1, 300 do
	mouse1click()
	game:GetService 'RunService'.RenderStepped:Wait()
end

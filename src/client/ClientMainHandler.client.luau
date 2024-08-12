local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local sprintRemote = game.ReplicatedStorage.Remotes:WaitForChild("Sprint")
local player = Players.LocalPlayer

UIS.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprintRemote:FireServer(true)
	end
end)

UIS.InputEnded:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprintRemote:FireServer(false)
	end
end)
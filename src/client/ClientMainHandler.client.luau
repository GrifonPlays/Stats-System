local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local sprintRemote = game.ReplicatedStorage.Remotes:WaitForChild("Sprint")
local player = Players.LocalPlayer

-- Send to server when LeftShift pressed to sprint
UIS.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.LeftShift then

		sprintRemote:FireServer(true)

	end
end)

-- Send to server when LeftShift downed to stop sprint
UIS.InputEnded:Connect(function(input, gpe)

	if input.KeyCode == Enum.KeyCode.LeftShift then

		sprintRemote:FireServer(false)

	end

end)
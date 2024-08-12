local Players = game:GetService("Players")
local StatsService = require(game.ReplicatedStorage.Shared.StatsService)
local sprintRemote = game.ReplicatedStorage.Remotes:WaitForChild("Sprint")
local CollectionService = game:GetService("CollectionService")


local foodTag = "Food"
local drinkTag = "Drink"
local healTag = "Heal"


local foodList = CollectionService:GetTagged(foodTag)
local drinkList = CollectionService:GetTagged(drinkTag)
local healList = CollectionService:GetTagged(healTag)



Players.PlayerAdded:Connect(function(player)

	StatsService:Start(player)


	player.CharacterAdded:Connect(function()

		StatsService:SetAllStats(player, "max")


		for i, consumable in pairs(foodList) do

			if consumable:IsA("Tool") then

				consumable.Activated:Connect(function()

					local char = consumable.Parent
					local player = Players:GetPlayerFromCharacter(char)


					StatsService:IncreaseStat(player, "Hunger", 20)

				end)

			end

		end


		for i, consumable in pairs(drinkList) do

			if consumable:IsA("Tool") then

				consumable.Activated:Connect(function()

					local char = consumable.Parent
					local player = Players:GetPlayerFromCharacter(char)


					StatsService:IncreaseStat(player, "Thirst", 20)

				end)

			end

		end


		for i, consumable in pairs(healList) do

			if consumable:IsA("Tool") then

				consumable.Activated:Connect(function()

					local char = consumable.Parent
					local player = Players:GetPlayerFromCharacter(char)

					StatsService:IncreaseStat(player, "Health", 20)

				end)

			end

		end

	end)

end)

sprintRemote.OnServerEvent:Connect(function(player, isSprinting)

	local char = player.Character


	if isSprinting then

		StatsService:AddStatDrain(player, "Stamina", 2000)
		StatsService:SetRegenDelay(player, "Stamina", math.huge)


		spawn(function()

			while true do

				task.wait(StatsService.UpdateInterval)


				if StatsService:IsDrainFreebie(player, "Stamina") then

					char.Humanoid.WalkSpeed = StatsService.DefaultWalkSpeed


					break

				end

			end

		end)


		char.Humanoid.WalkSpeed = StatsService.DefaultSprintSpeed

	else

		StatsService:AddStatDrain(player, "Stamina", -2000)
		StatsService:SetRegenDelay(player, "Stamina", StatsService.DefaultRegenDelay)
		char.Humanoid.WalkSpeed = StatsService.DefaultWalkSpeed

	end

end)
local StatsService = {}


local Players = game:GetService("Players")


-- Setting up stats variables
StatsService.DefaultHungerDrain = 300
StatsService.DefaultThirstDrain = 450
StatsService.DefaultHealthDrain = 0
StatsService.DefaultStaminaDrain = -800


StatsService.DefaultSprintSpeed = 28
StatsService.DefaultWalkSpeed = 16


StatsService.DefaultStarvingDamage = 400
StatsService.DefaultThirstDamage = 600


StatsService.DefaultHungerCap = 100
StatsService.DefaultThirstCap = 100
StatsService.DefaultHealthCap = 100
StatsService.DefaultStaminaCap = 100


StatsService.DefaultRegenDelay = 1


StatsService.UpdateInterval = .05



-- function to set regen delay
function StatsService:SetRegenDelay(player : Player, stat : string, number : number)

	local playerStats = player:WaitForChild("PlayerStats")
	local Stat = playerStats:FindFirstChild(stat)


	Stat:SetAttribute("RegenDelay", number)

end



-- startup function to make regen delay updates frequently
function StatsService:StartRegenDelayLoop(player : Player)

	local playerStats = player:WaitForChild("PlayerStats")


	for i, stat in pairs(playerStats:GetChildren()) do

		if stat:IsA("NumberValue") and stat:GetAttribute("RegenDelay") then

			spawn(function()

				while true do

					task.wait(StatsService.UpdateInterval)


					if stat:GetAttribute("RegenDelay") > 0 then

						stat:SetAttribute("RegenDelay", stat:GetAttribute("RegenDelay") - StatsService.UpdateInterval)

					else

						stat:SetAttribute("RegenDelay", 0)

					end

				end

			end)

		end

	end

end



-- function returns true if stat which is drains is at 0 and false if it still drains
function StatsService:IsDrainFreebie(player : Player, stat : string)

	local playerStats = player:WaitForChild("PlayerStats")
	local Stat = playerStats:FindFirstChild(stat)


	if Stat.Value > 0 then

		return false

	else

		return true

	end

end



-- function to add drain to the stat
function StatsService:AddStatDrain(player : Player, stat : string, drain : number)

	local playerStats = player:WaitForChild("PlayerStats")
	local Stat = playerStats:FindFirstChild(stat)


	if not Stat and stat ~= "all" then error("Invalid stat name") end


	if stat == "all" then

		for i, stat in pairs(playerStats:GetChildren()) do

			stat:SetAttribute("Drain", stat:GetAttribute("Drain") + drain)

		end

	else

		Stat:SetAttribute("Drain", Stat:GetAttribute("Drain") + drain)

	end

end



-- function to set all stats with specefic number
function StatsService:SetAllStats(player : Player, Number : string)

	local playerStats = player:WaitForChild("PlayerStats")


	for i, stat in pairs(playerStats:GetChildren()) do

		if stat:IsA("NumberValue") then

			if Number == "max" then

				stat.Value = stat:GetAttribute("Cap")

			else

				if Number > stat:GetAttribute("Cap") then

					stat.Value = stat:GetAttribute("Cap")

				else

					stat.Value = tonumber(Number)

				end

			end

		end

	end

end



-- function to set specefic stat`s value
function StatsService:SetStat(player : Player, Stat : string, Number : number)

	local playerStats = player:WaitForChild("PlayerStats")
	local ChosenStat = playerStats:FindFirstChild(Stat)


	if Number > ChosenStat:GetAttribute("Cap") then

		ChosenStat.Value = ChosenStat:GetAttribute("Cap")

	else

		ChosenStat.Value = Number

	end


	StatsService:UpdateDisplay(player)

end



-- function to add specefic number to a stat
function StatsService:IncreaseStat(player : Player, Stat : string, Number : number)

	local playerStats = player:WaitForChild("PlayerStats")
	local ChosenStat = playerStats:FindFirstChild(Stat)


	if ChosenStat.Value + Number > ChosenStat:GetAttribute("Cap") then

		ChosenStat.Value = ChosenStat:GetAttribute("Cap")

	else

		ChosenStat.Value += Number

	end

	StatsService:UpdateDisplay(player)

end



-- function to update GUI display and synchronize health value with player`s health
function StatsService:UpdateDisplay(player : Player)

	local playerStats = player:WaitForChild("PlayerStats")
	local HungerStat = playerStats:WaitForChild("Hunger")
	local ThirstStat = playerStats:WaitForChild("Thirst")
	local HealthStat = playerStats:WaitForChild("Health")
	local StaminaStat = playerStats:WaitForChild("Stamina")


	local StatGui = player.PlayerGui:WaitForChild("Stats"):WaitForChild("Stats")
	local HungerBar = StatGui:WaitForChild("HungerBar")
	local ThirstBar = StatGui:WaitForChild("ThirstBar")
	local HealthBar = StatGui:WaitForChild("HealthBar")
	local StaminaBar = StatGui:WaitForChild("StaminaBar")


	HungerBar.Value.Text = math.ceil(HungerStat.Value)
	HungerBar.ThatThing.Size = UDim2.new(HungerStat.Value/HungerStat:GetAttribute("Cap"), 0, 1, 0)


	ThirstBar.Value.Text = math.ceil(ThirstStat.Value)
	ThirstBar.ThatThing.Size = UDim2.new(ThirstStat.Value/ThirstStat:GetAttribute("Cap"), 0, 1, 0)


	HealthBar.Value.Text = math.ceil(HealthStat.Value)
	HealthBar.ThatThing.Size = UDim2.new(HealthStat.Value/HealthStat:GetAttribute("Cap"), 0, 1, 0)


	player.Character.Humanoid.Health = HealthStat.Value


	StaminaBar.ThatThing.Size = UDim2.new(StaminaStat.Value/StaminaStat:GetAttribute("Cap"), 0, 1, 0)

end



-- startup function to cycle the drains
function StatsService:StatsCycle(player : Player)

	local playerStats = player.PlayerStats
	local Hunger = playerStats.Hunger
	local Thirst = playerStats.Thirst
	local Health = playerStats.Health
	local Stamina = playerStats.Stamina


	spawn(function()

		while true do

			task.wait(StatsService.UpdateInterval)


			if Hunger.Value > 0 and Hunger.Value <= Hunger:GetAttribute("Cap") then

				Hunger.Value -= (Hunger:GetAttribute("Drain")/60)*StatsService.UpdateInterval

			else

				if Health.Value > 0 then

					Health.Value -= (StatsService.DefaultThirstDamage/60)*StatsService.UpdateInterval

				else

					Health.Value = 0

				end


				if Hunger.Value <= 0 then

					if Hunger.Value - (Hunger:GetAttribute("Drain")/60)*StatsService.UpdateInterval > 0 then

						if Hunger:GetAttribute("RegenDelay") >= 0 then

							Hunger.Value -= (Hunger:GetAttribute("Drain")/60)*StatsService.UpdateInterval

						end

					else

						Hunger.Value = 0

					end

				elseif Hunger.Value >= Hunger:GetAttribute("Cap") then

					if Hunger.Value - (Hunger:GetAttribute("Drain")/60)*StatsService.UpdateInterval < Hunger:GetAttribute("Cap") then

						if Hunger:GetAttribute("RegenDelay") >= 0 then

							Hunger.Value -= (Hunger:GetAttribute("Drain")/60)*StatsService.UpdateInterval

						end

					else

						Hunger.Value = Hunger:GetAttribute("Cap")

					end

				end

			end


			if Thirst.Value > 0 and Thirst.Value <= Thirst:GetAttribute("Cap") then

				if Thirst:GetAttribute("RegenDelay") > 0 and Thirst.Value - (Thirst:GetAttribute("Drain")/60)*StatsService.UpdateInterval < Thirst.Value then

					Thirst.Value -= (Thirst:GetAttribute("Drain")/60)*StatsService.UpdateInterval

				elseif Thirst:GetAttribute("RegenDelay") <= 0 then

					Thirst.Value -= (Thirst:GetAttribute("Drain")/60)*StatsService.UpdateInterval

				end

			else

				if Health.Value > 0 then

					Health.Value -= (StatsService.DefaultThirstDamage/60)*StatsService.UpdateInterval

				else

					Health.Value = 0

				end


				if Thirst.Value <= 0 then

					if Thirst.Value - (Thirst:GetAttribute("Drain")/60)*StatsService.UpdateInterval > 0 then

						if Thirst:GetAttribute("RegenDelay") >= 0 then

							Thirst.Value -= (Thirst:GetAttribute("Drain")/60)*StatsService.UpdateInterval

						end

					else

						Thirst.Value = 0

					end

				elseif Thirst.Value >= Thirst:GetAttribute("Cap") then

					if Thirst.Value - (Thirst:GetAttribute("Drain")/60)*StatsService.UpdateInterval < Thirst:GetAttribute("Cap") then

						if Thirst:GetAttribute("RegenDelay") >= 0 then

							Thirst.Value -= (Thirst:GetAttribute("Drain")/60)*StatsService.UpdateInterval

						end

					else

						Thirst.Value = Thirst:GetAttribute("Cap")

					end

				end

			end


			if Health.Value > 0 and Health.Value <= Health:GetAttribute("Cap") then

				if Health:GetAttribute("RegenDelay") > 0 and Health.Value - (Health:GetAttribute("Drain")/60)*StatsService.UpdateInterval < Health.Value then

					Health.Value -= (Health:GetAttribute("Drain")/60)*StatsService.UpdateInterval

				elseif Health:GetAttribute("RegenDelay") <= 0 then

					Health.Value -= (Health:GetAttribute("Drain")/60)*StatsService.UpdateInterval

				end

			else

				if Health.Value <= 0 then

					if Health.Value - (Health:GetAttribute("Drain")/60)*StatsService.UpdateInterval > 0 then

						if Health:GetAttribute("RegenDelay") >= 0 then

							Health.Value -= (Health:GetAttribute("Drain")/60)*StatsService.UpdateInterval

						end

					else

						Health.Value = 0

					end

				elseif Health.Value >= Health:GetAttribute("Cap") then

					if Health.Value - (Health:GetAttribute("Drain")/60)*StatsService.UpdateInterval < Health:GetAttribute("Cap") then

						if Health:GetAttribute("RegenDelay") >= 0 then

							Health.Value -= (Health:GetAttribute("Drain")/60)*StatsService.UpdateInterval

						end

					else

						Health.Value = Health:GetAttribute("Cap")

					end

				end

			end


			if Stamina.Value > 0 and Stamina.Value <= Stamina:GetAttribute("Cap") then

				if Stamina:GetAttribute("RegenDelay") > 0 and Stamina.Value - (Stamina:GetAttribute("Drain")/60)*StatsService.UpdateInterval < Stamina.Value then

					Stamina.Value -= (Stamina:GetAttribute("Drain")/60)*StatsService.UpdateInterval

				elseif Stamina:GetAttribute("RegenDelay") <= 0 then

					Stamina.Value -= (Stamina:GetAttribute("Drain")/60)*StatsService.UpdateInterval

				end

			else

				if Stamina.Value <= 0 then

					if Stamina.Value - (Stamina:GetAttribute("Drain")/60)*StatsService.UpdateInterval > 0 then

						if Stamina:GetAttribute("RegenDelay") >= 0 then

							Stamina.Value -= (Stamina:GetAttribute("Drain")/60)*StatsService.UpdateInterval

						end

					else

						Stamina.Value = 0

					end

				elseif Stamina.Value >= Stamina:GetAttribute("Cap") then

					if Stamina.Value - (Stamina:GetAttribute("Drain")/60)*StatsService.UpdateInterval < Stamina:GetAttribute("Cap") then

						if Stamina:GetAttribute("RegenDelay") >= 0 then

							Stamina.Value -= (Stamina:GetAttribute("Drain")/60)*StatsService.UpdateInterval

						end

					else

						Stamina.Value = Stamina:GetAttribute("Cap")

					end

				end

			end


			StatsService:UpdateDisplay(player)

		end

	end)

end



-- startup function to setup player stats in folder
function StatsService:SetupStats(player : Player)

	-- Creating folder with all player stats
	local playerStats = Instance.new("Folder")
	playerStats.Name = "PlayerStats"
	playerStats.Parent = player


	local Hunger = Instance.new("NumberValue")
	Hunger.Parent = playerStats
	Hunger.Name = "Hunger"
	Hunger.Value = 100
	Hunger:SetAttribute("Cap", StatsService.DefaultHungerCap)
	Hunger:SetAttribute("Drain", StatsService.DefaultHungerDrain)
	Hunger:SetAttribute("RegenDelay", 0)


	local Thirst = Instance.new("NumberValue")
	Thirst.Parent = playerStats
	Thirst.Name = "Thirst"
	Thirst.Value = 100
	Thirst:SetAttribute("Cap", StatsService.DefaultThirstCap)
	Thirst:SetAttribute("Drain", StatsService.DefaultThirstDrain)
	Thirst:SetAttribute("RegenDelay", 0)


	local Health = Instance.new("NumberValue")
	Health.Parent = playerStats
	Health.Name = "Health"
	Health.Value = 100
	Health:SetAttribute("Cap", StatsService.DefaultHealthCap)
	Health:SetAttribute("Drain", StatsService.DefaultHealthDrain)
	Health:SetAttribute("RegenDelay", 0)


	local Stamina = Instance.new("NumberValue")
	Stamina.Parent = playerStats
	Stamina.Name = "Stamina"
	Stamina.Value = 100
	Stamina:SetAttribute("Cap", StatsService.DefaultStaminaCap)
	Stamina:SetAttribute("Drain", StatsService.DefaultStaminaDrain)
	Stamina:SetAttribute("RegenDelay", 0)


end

function StatsService:Start(player)

	StatsService:SetupStats(player)
	StatsService:StatsCycle(player)
	StatsService:StartRegenDelayLoop(player)

end

return StatsService
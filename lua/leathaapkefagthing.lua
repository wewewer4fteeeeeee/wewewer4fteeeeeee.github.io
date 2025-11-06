local non67mangoabusers = game:GetService("Players")
local pconlylololoolll = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

task.spawn(function()
	repeat
		local ok = pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{
				Title = "",
				Text = "Made by Exploding_Car/Acethecreator (Discord)\nStop skidding, you script kiddies",
				Duration = 555
			})
		end)
		if ok then break end
		task.wait(0.5)
	until ok
end)

task.spawn(function()
	repeat
		local ok = pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{
				Title = "",
				Text = "How to use\nR to spam kill and yeah that is it",
				Duration = 555
			})
		end)
		if ok then break end
		task.wait(0.5)
	until ok
end)

setclipboard("discord.gg/FGRmuKR2")
task.wait(1.0)
task.spawn(function()
	repeat
		local ok = pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{
				Title = "",
				Text = "Discord Copied Join For More Scripts",
				Duration = 555
			})
		end)
		if ok then break end
		task.wait(0.5)
	until ok
end)

local localgooner = non67mangoabusers.LocalPlayer
local stupidspanishui = workspace:WaitForChild("OwnerPanel"):WaitForChild("AdminPanelGui")
stupidspanishui.Parent = localgooner:WaitForChild("PlayerGui")

local coolkilllall = stupidspanishui:WaitForChild("Events"):WaitForChild("KillFunction")
localgooner.CameraMode = Enum.CameraMode.Classic

pconlylololoolll.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.R then
		for _, player in pairs(non67mangoabusers:GetPlayers()) do
			if player ~= localgooner then
				task.spawn(function()
					coolkilllall:InvokeServer(player.Name)
				end)
				task.wait(0.05)
			end
		end
	elseif input.KeyCode == Enum.KeyCode.E then
		while task.wait(0.05) do
			for _, player in pairs(non67mangoabusers:GetPlayers()) do
				if player ~= localgooner then
					task.spawn(function()
						coolkilllall:InvokeServer(player.Name)
					end)
				end
			end
		end
	end
end)

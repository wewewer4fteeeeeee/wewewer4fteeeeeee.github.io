local non67mangoabusers = game:GetService("Players")
local pconlylololoolll = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local localgooner = non67mangoabusers.LocalPlayer
local stupidspanishui = workspace:WaitForChild("OwnerPanel"):WaitForChild("AdminPanelGui")
stupidspanishui.Parent = localgooner:WaitForChild("PlayerGui")

local coolkilllall = stupidspanishui:WaitForChild("Events"):WaitForChild("KillFunction")
local cloneBloody = replicatedStorage:WaitForChild("CloneBloodyLocalScripts")
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
		print("hi skidder RAAAAAA")
	end
end)

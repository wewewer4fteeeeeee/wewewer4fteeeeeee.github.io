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

-- Create main UI
local ScreenGui = Instance.new("ScreenGui", localgooner:WaitForChild("PlayerGui"))
ScreenGui.Name = "ExplodingCarUI"

local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0, 20, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 70)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BackgroundTransparency = 1
mainFrame.ZIndex = 10

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "made by exploding car"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(0, 0, 0)

local altText = Instance.new("TextLabel", mainFrame)
altText.Size = UDim2.new(1, 0, 0, 25)
altText.Position = UDim2.new(0, 0, 0, 20)
altText.BackgroundTransparency = 1
altText.Text = "exploding_dih (alt) on dc"
altText.Font = Enum.Font.Gotham
altText.TextSize = 12
altText.TextColor3 = Color3.fromRGB(0, 0, 0)

local killButton = Instance.new("TextButton", mainFrame)
killButton.Size = UDim2.new(1, -20, 0, 25)
killButton.Position = UDim2.new(0, 10, 1, -35)
killButton.BackgroundColor3 = Color3.fromRGB(100, 0, 160)
killButton.Text = "Kill All"
killButton.Font = Enum.Font.GothamBold
killButton.TextSize = 14
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.BorderSizePixel = 0

killButton.MouseButton1Click:Connect(function()
	local tween = tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.fromRGB(150, 0, 255)
	})
	tween:Play()
	for _, player in pairs(non67mangoabusers:GetPlayers()) do
		if player ~= localgooner then
			task.spawn(function()
				coolkilllall:InvokeServer(player.Name)
			end)
			task.wait(0.05)
		end
	end
	task.wait(0.3)
	mainFrame.BackgroundColor3 = Color3.fromRGB(45, 0, 70)
end)

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

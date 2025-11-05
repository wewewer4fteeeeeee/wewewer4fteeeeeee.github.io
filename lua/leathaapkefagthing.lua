local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local adminGui = workspace:WaitForChild("OwnerPanel"):WaitForChild("AdminPanelGui")
adminGui.Parent = localPlayer:WaitForChild("PlayerGui")

local killFunction = adminGui:WaitForChild("Events"):WaitForChild("KillFunction")
localgooner.CameraMode = Enum.CameraMode.Classic

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExplodingCarUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0, 20, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 0, 70)
mainFrame.BorderSizePixel = 2
mainFrame.ZIndex = 10
mainFrame.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "made by exploding car"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = mainFrame

local altText = Instance.new("TextLabel")
altText.Size = UDim2.new(1, 0, 0, 25)
altText.Position = UDim2.new(0, 0, 0, 25)
altText.BackgroundTransparency = 1
altText.Text = "exploding_dih (alt) on dc"
altText.Font = Enum.Font.Gotham
altText.TextSize = 12
altText.TextColor3 = Color3.fromRGB(255, 255, 255)
altText.Parent = mainFrame

local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(1, -20, 0, 25)
killButton.Position = UDim2.new(0, 10, 1, -35)
killButton.BackgroundColor3 = Color3.fromRGB(100, 0, 160)
killButton.Text = "Kill All"
killButton.Font = Enum.Font.GothamBold
killButton.TextSize = 16
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.BorderSizePixel = 0
killButton.AutoButtonColor = true
killButton.Parent = mainFrame

local function killAllPlayers()
	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.fromRGB(150, 0, 255)
	})
	tween:Play()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			task.spawn(function()
				killFunction:InvokeServer(player.Name)
			end)
			task.wait(0.05)
		end
	end
	task.wait(0.3)
	mainFrame.BackgroundColor3 = Color3.fromRGB(45, 0, 70)
end

killButton.MouseButton1Click:Connect(killAllPlayers)
killButton.TouchTap:Connect(killAllPlayers)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.R then
			killAllPlayers()
		elseif input.KeyCode == Enum.KeyCode.E then
			print("hi skidder RAAAAAA")
		end
	end
end)

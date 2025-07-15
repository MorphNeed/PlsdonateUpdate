if game.PlaceId ~= 8737602449 then return warn("❌ Bukan game Pls Donate.") end

local Players, HttpService, TeleportService = game:GetService("Players"), game:GetService("HttpService"), game:GetService("TeleportService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FeedTheCatGUI"
gui.ResetOnSpawn = false

-- Saved Settings
local settings = {
	autoChat = false,
	autoClaim = false,
	autoHop = false,
	customText = "Donate me to feed pixel cats 🐾🍣",
	guiPos = UDim2.new(0.5, -140, 0.1, 0)
}

pcall(function()
	local saved = readfile and readfile("feedcat_settings.json")
	if saved then
		local decoded = HttpService:JSONDecode(saved)
		for k, v in pairs(decoded) do
			settings[k] = v
		end
	end
end)

local function saveSettings()
	if writefile then
		writefile("feedcat_settings.json", HttpService:JSONEncode(settings))
	end
end

-- GUI Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 240)
frame.Position = settings.guiPos
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 0
frame.Name = "MainFrame"
frame.AnchorPoint = Vector2.new(0.5, 0)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Drag
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
frame.InputChanged:Connect(function(input)
	if dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		settings.guiPos = frame.Position
		saveSettings()
	end
end)
frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Title
local title = Instance.new("TextLabel", frame)
title.Text = "🐱 FeedTheCat GUI"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

-- Toggle
local function createToggle(name, posY, settingKey)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 260, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.Text = (settings[settingKey] and "✅ " or "🔲 ") .. name
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Name = settingKey
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		settings[settingKey] = not settings[settingKey]
		btn.Text = (settings[settingKey] and "✅ " or "🔲 ") .. name
		saveSettings()
	end)
end

createToggle("Auto Chat", 35, "autoChat")
createToggle("Auto Claim Booth", 70, "autoClaim")
createToggle("Auto Server Hop", 105, "autoHop")

-- TextBox
local input = Instance.new("TextBox", frame)
input.PlaceholderText = "Enter custom chat"
input.Text = settings.customText
input.Size = UDim2.new(0, 260, 0, 30)
input.Position = UDim2.new(0, 10, 0, 140)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
input.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

input.FocusLost:Connect(function()
	settings.customText = input.Text
	saveSettings()
end)

-- Reset GUI
local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(0, 260, 0, 25)
resetBtn.Position = UDim2.new(0, 10, 0, 185)
resetBtn.Text = "🔁 Reset GUI Position"
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 13
resetBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)

resetBtn.MouseButton1Click:Connect(function()
	frame.Position = UDim2.new(0.5, -140, 0.1, 0)
	settings.guiPos = frame.Position
	saveSettings()
end)

-- Auto Chat & Invite
local lastMsg = ""
local inviteList = {
	"Hey! 🐱 Come check out my booth!",
	"Stop by to feed some pixel kittens 🐾",
	"Help me feed the cats, donate today! 🐟",
	"Visit my booth and meet the meows! 🐈",
	"Your support saves virtual cat lives 😸"
}

task.spawn(function()
	while wait(10) do
		if settings.autoChat then
			local msg = settings.customText
			if msg and msg ~= "" and msg ~= lastMsg then
				lastMsg = msg
				game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
			end
		end
	end
end)

-- Auto Invite
task.spawn(function()
	while wait(30) do
		if settings.autoChat then
			local invite = inviteList[math.random(1, #inviteList)]
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(invite, "All")
		end
	end
end)

-- Auto Claim Booth
task.spawn(function()
	while wait(3) do
		if not settings.autoClaim then continue end
		local char = player.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
		for _, booth in pairs(workspace:WaitForChild("Booths"):GetChildren()) do
			local owner = booth:FindFirstChild("Owner")
			if owner and owner.Value == nil then
				firetouchinterest(booth.BoothUI.Claim, char.HumanoidRootPart, 0)
				firetouchinterest(booth.BoothUI.Claim, char.HumanoidRootPart, 1)
				break
			end
		end
	end
end)

-- Auto Server Hop
task.spawn(function()
	while wait(15) do
		if not settings.autoHop then continue end
		local boothAvailable = false
		for _, booth in pairs(workspace:WaitForChild("Booths"):GetChildren()) do
			if booth:FindFirstChild("Owner") and booth.Owner.Value == nil then
				boothAvailable = true
				break
			end
		end
		if not boothAvailable then
			pcall(function()
				TeleportService:Teleport(game.PlaceId)
			end)
		end
	end
end)

-- Auto Thank Donasi
local lastDonation = 0
task.spawn(function()
	while wait(2) do
		local boothUI = player.PlayerGui:FindFirstChild("Stand") or player.PlayerGui:FindFirstChild("BoothUI")
		if boothUI and boothUI:FindFirstChild("Raised") then
			local text = boothUI.Raised.Text:gsub("[^%d]", "")
			local current = tonumber(text) or 0
			if current > lastDonation then
				local diff = current - lastDonation
				local msg = "Thank you for donating " .. diff .. " Robux! 🥹❤️"
				game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
				lastDonation = current
			end
		end
	end
end)

-- [🔥 FeedCat GUI - Final Stable Version | Delta Mobile & PC Support]

if game.PlaceId ~= 8737602449 then return end

--===[ SAVE SETTINGS ]===--
local HttpService = game:GetService("HttpService")
local configFile = "feedcat_config.json"

local function loadConfig()
    local success, result = pcall(function()
        if readfile and isfile and isfile(configFile) then
            return HttpService:JSONDecode(readfile(configFile))
        end
    end)
    return success and result or {
        AutoChat = true,
        AutoThanks = true,
        AutoAFK = true
    }
end

local function saveConfig(config)
    if writefile then
        pcall(function()
            writefile(configFile, HttpService:JSONEncode(config))
        end)
    end
end

getgenv().FeedCat = loadConfig()

--===[ CHAT FUNCTION ]===--
local function chatMessage(message)
    local TextChatService = game:GetService("TextChatService")
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(message)
        end
    else
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
    end
end

--===[ AUTO CHAT GLOBAL ]===--
task.spawn(function()
    local messages = {
        "Saving for a better phone to make cool content!",
        "Goal: R$500 — Help a small creator grow big!",
        "Your small donation means a lot. Thank you!",
        "Support my journey to be a better creator!",
    }
    while task.wait(18) do
        if getgenv().FeedCat.AutoChat then
            chatMessage(messages[math.random(1, #messages)])
        end
    end
end)

--===[ AUTO THANKS ]===--
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

lp:WaitForChild("Leaderstats"):WaitForChild("Donated")
local lastDonation = lp.Leaderstats.Donated.Value

lp.Leaderstats.Donated:GetPropertyChangedSignal("Value"):Connect(function()
    if not getgenv().FeedCat.AutoThanks then return end
    local current = lp.Leaderstats.Donated.Value
    if current > lastDonation then
        local diff = current - lastDonation
        if diff < 5 then
            chatMessage("Thank you so much! Every Robux counts!")
        elseif diff < 25 then
            chatMessage("Thanks a lot for the generous support!")
        else
            chatMessage("You're amazing! Thank you for the big donation!")
        end
        lastDonation = current
    end
end)

--===[ ANTI-AFK ]===--
if getgenv().FeedCat.AutoAFK then
    task.spawn(function()
        local vu = game:GetService("VirtualUser")
        Players.LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end)
end

--===[ GUI INTERFACE ]===--
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "FeedCatGUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0, 20, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "📱 FeedCat Settings"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(30,30,30)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local minimize = Instance.new("TextButton", Frame)
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -30, 0, 0)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(50,50,50)
minimize.TextColor3 = Color3.fromRGB(255,255,255)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20

local icon = Instance.new("TextButton", ScreenGui)
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 10, 1, -50)
icon.Text = "🐾"
icon.BackgroundColor3 = Color3.fromRGB(40,40,40)
icon.TextColor3 = Color3.fromRGB(255,255,255)
icon.Visible = false
icon.Active = true
icon.Draggable = true

local function makeToggle(text, key, position)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, position)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text .. ": " .. (getgenv().FeedCat[key] and "ON" or "OFF")
    btn.MouseButton1Click:Connect(function()
        getgenv().FeedCat[key] = not getgenv().FeedCat[key]
        btn.Text = text .. ": " .. (getgenv().FeedCat[key] and "ON" or "OFF")
        saveConfig(getgenv().FeedCat)
    end)
end

makeToggle("Auto Chat", "AutoChat", 40)
makeToggle("Auto Thanks", "AutoThanks", 75)
makeToggle("Anti-AFK", "AutoAFK", 110)

-- Minimize & Restore GUI
minimize.MouseButton1Click:Connect(function()
    Frame.Visible = false
    icon.Visible = true
end)

icon.MouseButton1Click:Connect(function()
    Frame.Visible = true
    icon.Visible = false
end)

-- rejoin open source 406933 x Euro


local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
local PlaceId = game.PlaceId
local JobId = game.JobId
ScreenGui.Name = "AutoRejoin_30Min"
ScreenGui.Parent = game:GetService("CoreGui")
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
local UICorner = Instance.new("UICorner", MainFrame)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "AUTO REJOIN ( "..getgenv().rjcd.."MIN )"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainFrame
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.35, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Time left: 30:00"
StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 25
StatusLabel.Parent = MainFrame
Instance.new("UICorner", ToggleBtn)
local isRunning = true
local timeLeft = getgenv().rjcd * 60
local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end
local function Rejoin()
    local success, err = pcall(function()
if #Players:GetPlayers() <= 10 then
                lp:Kick("\nRejoining...")
                task.wait()
                TeleportService:Teleport(PlaceId, lp)
            else
                TeleportService:TeleportToPlaceInstance(PlaceId, JobId, lp) 
            end
    end)
end
local Title2 = Instance.new("TextLabel")
Title2.Size = UDim2.new(1, 0, 0, 175)
Title2.BackgroundTransparency = 1
Title2.Text = "Made By 406933"
Title2.TextColor3 = Color3.fromRGB(255, 255, 255)
Title2.Font = Enum.Font.GothamBold
Title2.TextSize = 13
Title2.Parent = MainFrame
task.spawn(function()
    while true do
        if isRunning then
            StatusLabel.Text = "Time left: " .. formatTime(timeLeft)
            if timeLeft <= 0 then
                StatusLabel.Text = "Rejoining..."
                Rejoin()
                break
            end
            timeLeft = timeLeft - 1
        end
        task.wait(1)
    end
end)

Как сделать тут меньше минут
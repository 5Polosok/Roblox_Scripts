getgenv().skibidi = true
getgenv().targetPlayerName = "" -- Игрок для атаки
getgenv().damageperhit = 666
getgenv().hitboxOffset = Vector3.new(0, 0, 0)
getgenv().msg = "/kill"
getgenv().killplayers = false -- Новый параметр для Mob Farm
getgenv().mobFarmEnabled = false -- Новый параметр для Mob Farm
getgenv().pickupEnabled = false -- Новый параметр для подбора предметов
getgenv().cooldown = 0.25 -- Кд для подбора

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local hitboxRemote = ReplicatedStorage.Logic.hitbox

-- Создаем GUI
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = library:CreateWindow({
    Title = 'Skibidi Hitbox',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    MobFarm = Window:AddTab('Mob Farm'),
    ItemPickup = Window:AddTab('Item Pickup'),
    Settings = Window:AddTab('Settings'),
}

-- Main Tab
local MainGroup = Tabs.Main:AddLeftGroupbox('Main Settings')

MainGroup:AddToggle('EnableScript', {
    Text = 'Enable Script',
    Default = true,
    Tooltip = 'Enable/disable the script',
    Callback = function(Value)
        getgenv().skibidi = Value
    end
})

MainGroup:AddSlider('DamagePerHit', {
    Text = 'Damage per hit',
    Default = 666,
    Min = 1,
    Max = 9999,
    Rounding = 0,
    Callback = function(Value)
        getgenv().damageperhit = Value
    end
})

MainGroup:AddInput('KillMessage', {
    Text = 'Kill message',
    Default = '/kill',
    Placeholder = 'Enter kill message',
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        getgenv().msg = Value
    end
})

local playerDropdown = MainGroup:AddDropdown('TargetPlayer', {
    Text = 'Target Player',
    Default = 'None',
    Values = {'None'},
    Multi = false,
    Callback = function(Value)
        getgenv().targetPlayerName = Value == 'None' and '' or Value
    end
})

-- Функция для обновления списка игроков
local function updatePlayersList()
    local playerNames = {'None'}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    playerDropdown:SetValues(playerNames)
end

-- Обновляем список игроков при запуске и при подключении/отключении игроков
updatePlayersList()
Players.PlayerAdded:Connect(updatePlayersList)
Players.PlayerRemoving:Connect(updatePlayersList)

MainGroup:AddButton('Refresh Players', function()
    updatePlayersList()
end)

MainGroup:AddButton('Send Hit Now', function()
    sendHitToPlayer()
end)

-- Mob Farm Tab
local MobFarmGroup = Tabs.MobFarm:AddLeftGroupbox('Mob Farm Settings')

MobFarmGroup:AddToggle('MobFarmEnabled', {
    Text = 'Enable Mob Farm',
    Default = false,
    Tooltip = 'Automatically attack mobs and players',
    Callback = function(Value)
        getgenv().mobFarmEnabled = Value
        if Value then
            startMobFarm()
        end
    end
})

MobFarmGroup:AddToggle('KillPlayers', {
    Text = 'Attack Players',
    Default = false,
    Tooltip = 'Also attack other players',
    Callback = function(Value)
        getgenv().killplayers = Value
    end
})

MobFarmGroup:AddLabel('Mob Farm will automatically attack all mobs and NPCs')

-- Item Pickup Tab
local ItemPickupGroup = Tabs.ItemPickup:AddLeftGroupbox('Item Pickup Settings')

ItemPickupGroup:AddToggle('PickupEnabled', {
    Text = 'Enable Auto Pickup',
    Default = false,
    Tooltip = 'Automatically pick up items',
    Callback = function(Value)
        getgenv().pickupEnabled = Value
        if Value then
            startItemPickup()
        end
    end
})

ItemPickupGroup:AddSlider('PickupCooldown', {
    Text = 'Pickup Cooldown',
    Default = 0.25,
    Min = 0.1,
    Max = 2,
    Rounding = 2,
    Callback = function(Value)
        getgenv().cooldown = Value
    end
})

ItemPickupGroup:AddLabel('Will pick up all tools except StandArrow and RokakakaFruit')

-- Settings Tab
local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Configuration')

SettingsGroup:AddInput('HitboxOffsetX', {
    Text = 'Hitbox Offset X',
    Default = '0',
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        getgenv().hitboxOffset = Vector3.new(tonumber(Value) or 0, getgenv().hitboxOffset.Y, getgenv().hitboxOffset.Z)
    end
})

SettingsGroup:AddInput('HitboxOffsetY', {
    Text = 'Hitbox Offset Y',
    Default = '0',
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        getgenv().hitboxOffset = Vector3.new(getgenv().hitboxOffset.X, tonumber(Value) or 0, getgenv().hitboxOffset.Z)
    end
})

SettingsGroup:AddInput('HitboxOffsetZ', {
    Text = 'Hitbox Offset Z',
    Default = '0',
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        getgenv().hitboxOffset = Vector3.new(getgenv().hitboxOffset.X, getgenv().hitboxOffset.Y, tonumber(Value) or 0)
    end
})

-- Theme Manager
ThemeManager:SetLibrary(library)
ThemeManager:SetFolder('SkibidiHitbox')
ThemeManager:ApplyToTab(Tabs.Settings)

-- Save Manager
SaveManager:SetLibrary(library)
SaveManager:SetFolder('SkibidiHitbox')
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- Функция для Mob Farm
local mobFarmThread
function startMobFarm()
    if mobFarmThread then
        task.cancel(mobFarmThread)
    end
    
    mobFarmThread = task.spawn(function()
        while getgenv().mobFarmEnabled do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
                local voiceline = character:FindFirstChild("Torso") and character.Torso:FindFirstChild("voiceline")
                
                for _, v in pairs(Workspace:GetChildren()) do
                    if not getgenv().mobFarmEnabled then break end
                    
                    if not v:FindFirstChild("ClickDetector") and v:IsA("Model") and v ~= character and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        local isPlayer = Players:GetPlayerFromCharacter(v)
                        
                        if (not isPlayer or getgenv().killplayers) and v.Name ~= "Rubber Dummy" then
                            local humanoidRootPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Head")
                            if humanoidRootPart and rightArm then
                                pcall(function()
                                    hitboxRemote:InvokeServer(
                                        0,
                                        rightArm,
                                        humanoidRootPart.CFrame * CFrame.new(getgenv().hitboxOffset),
                                        getgenv().damageperhit,
                                        voiceline,
                                        v.Humanoid,
                                        false,
                                        false,
                                        false,
                                        false
                                    )
                                end)
                                task.wait()
                            end
                        end
                    end
                end
            end
            task.wait()
        end
    end)
end

-- Функция для подбора предметов
local pickupThread
function startItemPickup()
    if pickupThread then
        task.cancel(pickupThread)
    end
    
    pickupThread = task.spawn(function()
        while getgenv().pickupEnabled do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                
                -- Используем быстрый перебор
                local children = workspace:GetChildren()
                for i = 1, #children do
                    if not getgenv().pickupEnabled then break end
                    
                    local v = children[i]
                    if v:IsA("Tool") and v:FindFirstChild("Handle") and v.Name ~= "StandArrow" and v.Name ~= "RokakakaFruit" then
                        pcall(function()
                            firetouchinterest(humanoidRootPart, v.Handle, 0)
                            task.wait()
                            firetouchinterest(humanoidRootPart, v.Handle, 1)
                        end)
                    end
                end
            end
            task.wait(getgenv().cooldown)
        end
    end)
end

-- Функция для отправки ремоута
local function sendHitToPlayer()
    if getgenv().targetPlayerName == "" or getgenv().targetPlayerName == "None" then
        library:Notify("No target player selected!", 3)
        return
    end
    
    local character = LocalPlayer.Character
    if not character then 
        library:Notify("Character not found!", 3)
        return 
    end
    
    local targetPlayer = Players:FindFirstChild(getgenv().targetPlayerName)
    if not targetPlayer or not targetPlayer.Character then 
        library:Notify("Target player not found!", 3)
        return 
    end
    
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
    local voiceline = character:FindFirstChild("Torso") and character.Torso:FindFirstChild("voiceline")
    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    
    if not rightArm then 
        library:Notify("Right Arm not found!", 3)
        return 
    end
    if not targetHumanoid then 
        library:Notify("Target humanoid not found!", 3)
        return 
    end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Head")
    if not targetRoot then 
        library:Notify("Target root part not found!", 3)
        return 
    end
    
    local enemyCFrame = targetRoot.CFrame * CFrame.new(getgenv().hitboxOffset)
    
    pcall(function()
        hitboxRemote:InvokeServer(
            0,
            rightArm,
            enemyCFrame,
            getgenv().damageperhit,
            voiceline,
            targetHumanoid,
            false,
            false,
            false,
            false
        )
        library:Notify("Hit sent to: " .. getgenv().targetPlayerName, 3)
    end)
end

-- Подключаемся к событию чата
local function onChatMessage(message)
    if string.lower(message) == string.lower(getgenv().msg) then
        sendHitToPlayer()
    end
end

-- Получаем сервис чата
local TextChatService = game:GetService("TextChatService")

-- Создаем подключение к чату
local function setupChatListener()
    -- Для нового чата (TextChatService)
    if TextChatService then
        local channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
        if channel then
            channel.OnIncomingMessage = function(message)
                if message.TextSource then
                    local player = Players:GetPlayerByUserId(message.TextSource.UserId)
                    if player == LocalPlayer then
                        onChatMessage(message.Text)
                    end
                end
            end
        end
    end
    
    -- Для старого чата
    local oldChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if oldChatEvents then
        local sayMessageRequest = oldChatEvents:FindFirstChild("SayMessageRequest")
        if sayMessageRequest then
            sayMessageRequest.OnClientEvent:Connect(function(message)
                onChatMessage(message)
            end)
        end
    end
end

-- Запускаем прослушиватель чата
setupChatListener()

-- PlayerChatted event
local function setupPlayerChatted()
    local playerChattedEvent = ReplicatedStorage:FindFirstChild("PlayerChatted")
    if playerChattedEvent then
        playerChattedEvent.OnClientEvent:Connect(function(player, message)
            if player == LocalPlayer then
                onChatMessage(message)
            end
        end)
    end
end

setupPlayerChatted()

library:Notify("Skibidi Hitbox GUI Loaded!", 5)

-- Основной цикл
while task.wait(1) do
    if not getgenv().skibidi then
        if mobFarmThread then
            task.cancel(mobFarmThread)
        end
        if pickupThread then
            task.cancel(pickupThread)
        end
        break
    end
end
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

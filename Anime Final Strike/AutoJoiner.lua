if not getgenv().TpToEventStatement or game.PlaceId ~= 16946008847 then return end
repeat task.wait() until game:IsLoaded()

-- Ожидание загрузки всех аккаунтов
while #game:GetService("Players"):GetPlayers() ~= getgenv().AmountOfAccounts do
    task.wait(1)
    print("Waiting till other alts join")
end

local function countPlayersNearPortal()
    local portalPosition = Vector3.new(-10, 256.6, -112)
    local playersNearPortal = 0
    
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - portalPosition).Magnitude
            if distance < 20 then -- Расстояние 20 юнитов от портала
                playersNearPortal = playersNearPortal + 1
            end
        end
    end
    
    return playersNearPortal
end

local function activatePortal()
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Телепортация к порталу
    humanoidRootPart.CFrame = CFrame.new(-10, 256.6, -112)
    task.wait(1)
    
    -- Проверка количества игроков у портала
    local playersNearPortal = countPlayersNearPortal()
    print("Players near portal:", playersNearPortal)
    
    if game:GetService("Players").LocalPlayer.Name == "edik899" and playersNearPortal >= AmountOfAccounts then
        local args = {
            "PlayBlackCloverEvent"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
        print("Activated portal with all players present!")
        return true
    elseif game:GetService("Players").LocalPlayer.Name ~= "edik899" then
        -- Для остальных аккаунтов используем fireproximityprompt
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and (descendant.Parent.Position - humanoidRootPart.Position).Magnitude < 10 then
                fireproximityprompt(descendant)
                print("ProximityPrompt activated for", game:GetService("Players").LocalPlayer.Name)
                return true
            end
        end
    else
        print("Not enough players near portal ("..playersNearPortal.."/"..AmountOfAccounts..")")
        return false
    end
end

while task.wait(1) do
    if #game:GetService("Workspace").Characters:GetChildren() == AmountOfAccounts then
        local success = activatePortal()
        if success then
            print("Portal activation successful for", game:GetService("Players").LocalPlayer.Name)
            break -- Выход из цикла после успешной активации
        else
            print("Failed to activate portal, retrying...")
        end
    end
end

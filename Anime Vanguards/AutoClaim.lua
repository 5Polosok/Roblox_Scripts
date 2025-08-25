if game.PlaceId ~= 16146832113 then return end
local delay = 0.1
local playerLevel = game:GetService("Players").LocalPlayer:GetAttribute("Level")
local RedeemCodes = function() 
    local codes = {"UnendingRage", "TheStrongest", "THEONE", "SUMMER", "IAMTHEONEWHODECIDES", "Sasageyo"}
    for _,v in pairs(codes) do
        local args = {
            v
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("CodesEvent"):FireServer(unpack(args))
        task.wait(delay)
    end
end
local ClaimLevel = function()
    local playerLevel = game:GetService("Players").LocalPlayer:GetAttribute("Level") or 0
    
    if playerLevel < 5 then
        print("Уровень меньше 5, наград нет")
        return
    end
    
    -- Округляем до ближайшего меньшего числа, оканчивающегося на 0 или 5
    local lastDigit = playerLevel % 10
    local targetLevel
    
    if lastDigit < 5 then
        targetLevel = playerLevel - lastDigit -- Округляем до 0 (например: 13 → 10)
    else
        targetLevel = playerLevel - (lastDigit - 5) -- Округляем до 5 (например: 17 → 15)
    end
    
    -- Убеждаемся, что уровень не меньше 5
    if targetLevel < 5 then
        print("Нет доступных наград")
        return
    end
    
    print("Текущий уровень:", playerLevel, "| Забираем награды до уровня:", targetLevel)
    
    -- Забираем награды для всех уровней, кратных 5, начиная с 5
    for lvl = 5, targetLevel, 5 do
        local args = {
            "Claim",
            lvl 
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("Milestones"):WaitForChild("MilestonesEvent"):FireServer(unpack(args))
        print("Claimed Level: ", lvl)
        task.wait(delay)
    end
end

local main = function()
    if getgenv().redeemcodes then task.spawn(function() RedeemCodes() end) end
    if getgenv().claimlevel then task.spawn(function() ClaimLevel() end) end
end
task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    task.wait(3)
    main()
end)
-- getgenv().redeemcodes = true
-- getgenv().claimlevel = true
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/Anime%20Vanguards/AutoClaim.lua"))()
if game.PlaceId ~= 16146832113 then return end
local delay = 0.25
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
    for lvl=100, 0, -5 do
        local args = {
            "Claim",
            lvl 
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("Milestones"):WaitForChild("MilestonesEvent"):FireServer(unpack(args))
        task.wait(delay)
    end
end

local main = function()
    if getgenv().redeemcodes then RedeemCodes() end
    if getgenv().claimlevel then ClaimLevel() end
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
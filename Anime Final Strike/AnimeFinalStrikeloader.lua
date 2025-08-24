--AutoJoiner loadstring
task.spawn(function()
    --AutoJoiner Statements
    getgenv().TpToEventStatement = false
    getgenv().AmountOfAccounts = 4
    loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/Anime%20Final%20Strike/AutoJoiner.lua"))()
end)

--AutoClaimer loadstring
task.spawn(function()
    --AutoClaimer Statements
    getgenv().BuyRRS = true
    getgenv().CollectDaily = true
    getgenv().SpinWheel = true
    getgenv().RedeemCodes - true 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/Anime%20Final%20Strike/ClaimRewards.lua"))()
end)

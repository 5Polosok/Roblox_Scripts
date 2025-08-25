local Loader = function()
    --Anime Final Strike
    if game.PlaceId == 16946008847 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/FEscripts/FPSBoost.lua"))()
        --AutoJoiner Statements
        getgenv().TpToEventStatement = true
        getgenv().AmountOfAccounts = 3
        --ClaimAll Statements
        getgenv().BuyRRS = true
        getgenv().CollectDaily = true
        getgenv().SpinWheel = true
        getgenv().RedeemCodes = true 
        --loadstring
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/Anime%20Final%20Strike/AnimeFinalStrikeloader.lua"))()
        task.wait(1)
        return 
    end

    --Anime Vanguards
    if game.PlaceId == 16146832113 then
        getgenv().enable_fpscap = true
        getgenv().fps_amount = 30
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/FEscripts/setfpslimit.lua"))()
        --AutoClaimer statements
        getgenv().redeemcodes = true
        getgenv().claimlevel = true
        --loadstring
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/Anime%20Vanguards/AVScriptLoader.lua"))()
        task.wait(1)
        return 
    end

    --ASTDX
    if game.PlaceId == 17687504411 then
        --UseParser statement
        getgenv().UseParser = false
        --loadstring
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/ASTDX/ASTDXLoader.lua"))()
        task.wait(1)
        return
    end
end

task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    task.wait(1)
    
    Loader()
end)

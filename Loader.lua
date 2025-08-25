local Loader = function()
    getgenv().setfpscap = true
    getgenv().fpsamount = 20
    --Anime Final Strike
    if game.PlaceId == 16946008847 then
        --AutoJoiner Statements
        getgenv().TpToEventStatement = false
        getgenv().AmountOfAccounts = 4
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
    task.wait(3)
    
    Loader()
end)

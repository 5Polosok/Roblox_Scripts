local Loader = function()
    --Anime Final Strike
    if game.PlaceId == 16946008847 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/FEscripts/FPSBoost.lua"))()
        --AutoRestart Statements
           
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
        return 
    end

    --Anime Vanguards
    if game.PlaceId == 16146832113 or game.PlaceId == 16277809958 then
        getgenv().enable_fpscap = true
        getgenv().fps_amount = 30
        pcall(function()
            if getgenv().enable_fpscap then
                setfpscap(getgenv().fps_amount)
            end
        end)
        --AutoClaimer statements
        getgenv().redeemcodes = true
        getgenv().claimlevel = true
        task.wait(1)
        --loadstring
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/Anime%20Vanguards/AVScriptLoader.lua"))()
        return 
    end

    --ASTDX
    if game.PlaceId == 17687504411 then
        --UseParser statement
        getgenv().UseParser = false
        --loadstring
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/ASTDX/ASTDXLoader.lua"))()
        return
    end
end

task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    else
        print("SKIBIDI LOADED")
    end
    task.wait(1)
    Loader()
end)

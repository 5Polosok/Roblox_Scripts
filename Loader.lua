--Anime Final Strike
if game.PlaceId == 16946008847 then
    --AutoJoiner Statements
    getgenv().TpToEventStatement = false
    getgenv().AmountOfAccounts = 4
    --ClaimAll
    getgenv().BuyRRS = true
    getgenv().CollectDaily = true
    getgenv().SpinWheel = true
    getgenv().RedeemCodes - true 
    --loadstring
    loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/Anime%20Final%20Strike/AnimeFinalStrikeloader.lua"))()

    --Anime Vanguards
elseif gane.PlaceId == 16146832113 then
    --AutoClaimer statements
    getgenv().redeemcodes = true
    getgenv().claimlevel = true
    loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/Anime%20Vanguards/AVScriptLoader.lua"))()

--ASTDX
elseif game.PlaceId == 17687504411 then
    getgenv().UseParser = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/ASTDX/ASTDXLoader.lua"))()
end
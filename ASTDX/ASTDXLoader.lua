task.spawn(function()
    if getgenv().UseParser = true then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/ASTDX/AutoClaimerParser.lua"))()
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/ASTDX/AutoClaimerLocal.lua"))()
    end    
end)

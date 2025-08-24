if game.PlaceId ~= 16146832113 then return end
--consts
local Slider = game:GetService("Players").LocalPlayer.PlayerGui.Windows.Settings.Holder.Main.ScrollingFrame.Gameplay.AutoSkipWaves.Slider
local Ball = Slider.Ball
local UIStroke = Ball.UIStroke
local Color = UIStroke.color

--AutoToggle SkipWaves
local ToggleAutoSkipWaves = function()
    if Color == Color3.fromRGB(255, 0, 75) then
        local args = {
            "Toggle",
            "AutoSkipWaves"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("Settings"):WaitForChild("SettingsEvent"):FireServer(unpack(args))
    else
        print("AutoSkipWaves already toggled on")
    end
end

task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    task.wait(3)
    
    ToggleAutoSkipWaves()
end)
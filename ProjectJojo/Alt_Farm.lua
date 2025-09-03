-- === Настройки ===
getgenv().mobFarmEnabled = true          -- Включить фарм мобов
getgenv().killplayers = false            -- Атаковать игроков (true/false)
getgenv().pickupEnabled = true           -- Включить подбор предметов
getgenv().pickupCooldown = 0.25          -- Задержка между подбором

-- === Сервисы ===
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- === Функция: фарм мобов ===
local mobFarmThread = nil
local LocalPlayer = Players.LocalPlayer
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)
task.spawn(function()
    setfpscap(60)
end)
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/FEscripts/FPSBoost.lua"))()
end)
local function startMobFarm()
    if mobFarmThread then
        task.cancel(mobFarmThread)
    end

    mobFarmThread = task.spawn(function()
        while getgenv().mobFarmEnabled do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
                local voiceline = character:FindFirstChild("Torso") and character.Torso:FindFirstChild("voiceline")

                for _, v in ipairs(Workspace:GetChildren()) do
                    if not getgenv().mobFarmEnabled then break end

                    -- Проверяем, что это живой NPC или игрок (но не Rubber Dummy)
                    if v:IsA("Model")
                        and v ~= character
                        and v:FindFirstChild("Humanoid")
                        and v.Humanoid.Health > 0
                        and not v:FindFirstChild("ClickDetector")
                        and v.Name ~= "Rubber Dummy"
                    then
                        local isPlayer = Players:GetPlayerFromCharacter(v)

                        -- Атакуем только мобов, или игроков если killplayers = true
                        if (not isPlayer or getgenv().killplayers) then
                            local targetPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Head")
                            if targetPart and rightArm then
                                pcall(function()
                                    -- 🔥 Здесь вызывается серверный ремоут (адаптируй под свою игру)
                                    game:GetService("ReplicatedStorage").Logic.hitbox:InvokeServer(
                                        0,
                                        rightArm,
                                        targetPart.CFrame * CFrame.new(0, 0, 0),
                                        666, -- урон
                                        voiceline,
                                        v.Humanoid,
                                        false, false, false, false
                                    )
                                end)
                                task.wait(0.1) -- небольшая задержка между ударами
                            end
                        end
                    end
                end
            end
            task.wait(0.1) -- задержка между циклами
        end
    end)
end

-- === Функция: авто-подбор предметов ===
local pickupThread = nil

local function startItemPickup()
    if pickupThread then
        task.cancel(pickupThread)
    end

    pickupThread = task.spawn(function()
        while getgenv().pickupEnabled do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart

                -- Перебираем все объекты в workspace
                local children = Workspace:GetChildren()
                for i = 1, #children do
                    local v = children[i]
                    if v:IsA("Tool")
                        and v:FindFirstChild("Handle")
                        and (v.Name ~= "StandArrow" and v.Name ~= "RokakakaFruit")
                    then
                        pcall(function()
                            firetouchinterest(rootPart, v.Handle, 0)
                            task.wait(0.05)
                            firetouchinterest(rootPart, v.Handle, 1)
                        end)
                    end
                end
            end
            task.wait(getgenv().pickupCooldown) -- настраиваемая задержка
        end
    end)
end

-- === Запуск систем ===
task.spawn(function()
    while true do
        if getgenv().mobFarmEnabled and (not mobFarmThread or not task.isrunning(mobFarmThread)) then
            startMobFarm()
        elseif not getgenv().mobFarmEnabled and mobFarmThread then
            task.cancel(mobFarmThread)
            mobFarmThread = nil
        end

        if getgenv().pickupEnabled and (not pickupThread or not task.isrunning(pickupThread)) then
            startItemPickup()
        elseif not getgenv().pickupEnabled and pickupThread then
            task.cancel(pickupThread)
            pickupThread = nil
        end

        task.wait(1) -- редкая проверка состояния
    end
end)

print("✅ Mob Farm & Auto Pickup запущены")

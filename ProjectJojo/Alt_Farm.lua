-- === Настройки ===
getgenv().mobFarmEnabled = true
getgenv().killplayers = false
getgenv().pickupEnabled = true
getgenv().pickupCooldown = 0.25
getgenv().webhook_url_report = "https://discord.com/api/webhooks/1279195149775409163/7wgJt9UIJmhCTZooeYonVMtYe1DsCRBLJgI-536_lH7fb7C3M3E3i3BIoeEm41D_Xozu" -- для отчётов

-- === Сервисы ===
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local vu = game:GetService("VirtualUser")

-- === Анти-афк (task.spawn) ===
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

-- === FPS Boost (task.spawn) ===
-- task.spawn(function()
--     loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/FEscripts/FPSBoost.lua"))()
-- end)

-- === Фарм мобов (task.spawn) ===
task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().mobFarmEnabled then
            task.wait(1)
            continue
        end

        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
            task.wait(1)
            continue
        end

        local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
        local voiceline = character:FindFirstChild("Torso") and character.Torso:FindFirstChild("voiceline")

        for _, v in ipairs(Workspace:GetChildren()) do
            if not getgenv().mobFarmEnabled then break end

            if v:IsA("Model")
                and v ~= character
                and v:FindFirstChild("Humanoid")
                and v.Humanoid.Health > 0
                and not v:FindFirstChild("ClickDetector")
                and v.Name ~= "Rubber Dummy"
            then
                local isPlayer = Players:GetPlayerFromCharacter(v)
                if (not isPlayer or getgenv().killplayers) then
                    local targetPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Head")
                    if targetPart and rightArm then
                        pcall(function()
                            ReplicatedStorage.Logic.hitbox:InvokeServer(
                                0, rightArm, targetPart.CFrame, 666, voiceline, v.Humanoid,
                                false, false, false, false
                            )
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end


    end
end)

-- === Подбор инструментов (task.spawn) ===
task.spawn(function()
    while task.wait(getgenv().pickupCooldown) do
        if not getgenv().pickupEnabled then
            task.wait(1)
            continue
        end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            task.wait(1)
            continue
        end

        for _, tool in ipairs(Workspace:GetChildren()) do
            if tool:IsA("Tool")
                and tool:FindFirstChild("Handle")
                and not table.find({"StandArrow", "RokakakaFruit"}, tool.Name)
            then
                pcall(function()
                    firetouchinterest(rootPart, tool.Handle, 0)
                    task.wait(0.05)
                    firetouchinterest(rootPart, tool.Handle, 1)
                end)
            end
        end

    end
end)

-- === Подбор MoneyBag (task.spawn) ===
task.spawn(function()
    while task.wait(getgenv().pickupCooldown) do
        if not getgenv().pickupEnabled then
            task.wait(1)
            continue
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "MoneyBag" then
                local cd = obj:FindFirstChild("ClickDetector")
                local pp = obj:FindFirstChild("ProximityPrompt")

                if cd then
                    pcall(fireclickdetector, cd)
                elseif pp then
                    pcall(fireproximityprompt, pp)
                end
            end
        end

    end
end)

-- === Отправка вебхука каждые 30 минут (task.spawn) ===
task.spawn(function()
    while true do
        task.wait(30 * 60) -- 30 минут

        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local character = LocalPlayer.Character
        local timeText = "N/A"

        -- Получаем время
        local statUI = LocalPlayer:FindFirstChild("PlayerGui")
            and LocalPlayer.PlayerGui:FindFirstChild("statUI")
        if statUI and statUI:FindFirstChild("time") then
            timeText = statUI.time.Text
        end

        -- Сбор инвентаря
        local inventory = {}
        local function countTools(parent)
            if not parent then return end
            for _, tool in ipairs(parent:GetChildren()) do
                if tool:IsA("Tool") then
                    inventory[tool.Name] = (inventory[tool.Name] or 0) + 1
                end
            end
        end

        countTools(backpack)
        countTools(character)

        -- Формируем список
        local itemsList = ""
        for item, count in pairs(inventory) do
            itemsList = itemsList .. string.format("**%s** ×%d\n", item, count)
        end
        if itemsList == "" then itemsList = "*Пусто*" end

        -- 📬 Отправка вебхука (в стиле твоего автостенд-скрипта)
        local function sendWebhook()
            local httpRequest = http_request or (syn and syn.request) or request
            if not httpRequest or not getgenv().webhook_url_report then return end

            local embed = {
                title = "📊 30-минутный отчёт",
                description = "**" .. LocalPlayer.Name .. "** — статистика инвентаря",
                fields = {
                    {
                        name = "⏰ Игровое время",
                        value = timeText,
                        inline = true
                    },
                    {
                        name = "🎒 Предметы в инвентаре",
                        value = itemsList,
                        inline = false
                    }
                },
                color = 5814783,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
                footer = { text = "Auto Report System" },
                author = {
                    name = "Игрок: " .. LocalPlayer.Name,
                    icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
                }
            }

            local data = { embeds = { embed } }
            local body = HttpService:JSONEncode(data)

            pcall(function()
                httpRequest({
                    Url = getgenv().webhook_url_report,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body
                })
            end)
        end

        sendWebhook()
    end
end)

print("✅ Все системы запущены через task.spawn — Mob Farm, Pickup, Money, Webhook Report")
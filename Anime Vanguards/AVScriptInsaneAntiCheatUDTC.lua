-- 🔒 Безопасная инициализация
if not getgenv then
    return warn("Скрипт работает только в среде с getgenv (Synapse X, Krnl)")
end
if not getgenv().FarmAltsFunpay then return end

-- ⚙️ Глобальные настройки
getgenv().days_amount = 3
getgenv().AutoUpgradeEnabled = true
getgenv().MatchRestartEnabled = true

-- 🔗 Вебхук
if not getgenv().AV_WEBHOOK_URL or getgenv().AV_WEBHOOK_URL == "" then
    warn("⚠️ Вебхук URL не задан! Используй: getgenv().AV_WEBHOOK_URL = 'https://...'")
end

-- 📍 Позиции для юнитов
local TARGET_POSITIONS = {
    Vector3.new(424.83978271484375, 3.7291393280029297, -350.6957702636719),
    Vector3.new(424.9408874511719, 3.7291393280029297, -353.44927978515625),
    Vector3.new(430.9632873535156, 3.7291393280029297, -351.3844299316406),
    Vector3.new(430.8381042480469, 3.7291393280029297, -354.10968017578125),
    Vector3.new(425.84222412109375, 3.7291393280029297, -347.7817687988281),
    Vector3.new(428.85882568359375, 3.7291393280029297, -346.37255859375)
}

-- ⏳ Задержка
local function randomDelay(min, max)
    task.wait(math.random(min * 100, max * 100) / 100)
end

-- ⚙️ ОСНОВНАЯ ЛОГИКА
local function main()
    local placeId = game.PlaceId
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui", 10)

    -- ✅ Анти-афк
    local function enableAntiIdle()
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
    enableAntiIdle()

    if placeId == 16146832113 then
        -- 🌞 Меню: дейлики, батлпасс, старт
        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player:FindFirstChild("PlayerGui")
        repeat task.wait() until playerGui:FindFirstChild("Windows")

        -- Выбор юнита
        pcall(function()
            game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("UnitSelectionEvent")
                :FireServer("Select", "Luffo")
            print("✅ Юнит Luffo выбран")
            randomDelay(0.3, 0.7)
        end)

        -- Экипировка
        pcall(function()
            local units = playerGui.Windows.Units.Holder.Main.Units
            for _, frame in pairs(units:GetChildren()) do
                if frame:IsA("Frame") and frame.Name ~= "BuyMoreSpace" then
                    game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("EquipEvent")
                        :FireServer("Equip", frame.Name)
                    print(`✅ Экипирован: {frame.Name}`)
                    break
                end
            end
        end)

        -- Дейлики
        pcall(function()
            local event = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("DailyRewardEvent")
            for _, season in pairs({"Summer", "Spring", "Special"}) do
                for day = 1, getgenv().days_amount do
                    event:FireServer("Claim", {season, day})
                    print(`🎁 Получено: {season} — День {day}`)
                    randomDelay(0.2, 0.4)
                end
            end
        end)

        -- Батлпасс
        pcall(function()
            game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("BattlepassEvent")
                :FireServer("ClaimAll")
            print("🎖️ Все награды Battlepass получены")
            randomDelay(0.5, 1.2)
        end)

        -- Квесты
        pcall(function()
            game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Quests"):WaitForChild("ClaimQuest")
                :FireServer("ClaimAll")
            print("📜 Все квесты получены")
            randomDelay(0.5, 1.0)
        end)

        -- Старт матча
        pcall(function()
            local lobby = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("LobbyEvent")
            lobby:FireServer("AddMatch", {
                Difficulty = "Normal",
                Act = "Act1",
                StageType = "Story",
                Stage = "Stage1",
                FriendsOnly = true
            })
            randomDelay(0.3, 0.7)
            lobby:FireServer("StartMatch")
            print("🚀 Матч запущен!")
        end)

    elseif placeId == 16277809958 then
        -- 🔥 Боёвка

        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player.Character
        repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")

        -- FPS
        pcall(function()
            local map = game.Workspace:FindFirstChild("Map")
            if map then
                for _, v in pairs(map:GetChildren()) do
                    if v.Name ~= "Assets" and v.Name ~= "Terrain" then
                        pcall(v.Destroy, v)
                    end
                end
            end
        end)

        task.wait(0.5)

        -- Пропуск волны
        local function fireSkipWave()
            spawn(function()
                for i = 1, 3 do
                    pcall(function()
                        game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("SkipWaveEvent")
                            :FireServer("Skip")
                        print("⏭️ Волна пропущена")
                        return
                    end)
                    task.wait(1)
                end
            end)
        end

        -- Проверка активности
        local function isGameActive()
            return playerGui:FindFirstChild("Hotbar") and not playerGui:FindFirstChild("EndScreen")
        end

        -- Волна через GUI
        local function isWaveActive()
            local hud = playerGui:FindFirstChild("HUD")
            local frame = hud and hud:FindFirstChild("Map") and hud.Map:FindFirstChild("WavesAmount")
            local textObj = frame and frame:FindFirstChild("ContentText")
            if not textObj then return false end
            local current = tonumber((string.split(textObj.Text, "/"))[1]) or 0
            return current > 0
        end

        local function waitForWave()
            print("⏳ Ожидаем начало волны...")
            repeat task.wait(1) until isWaveActive()
            print("🔥 Волна началась!")
        end

        -- Деньги
        local function getMoney()
            local hotbar = playerGui:FindFirstChild("Hotbar")
            if not hotbar then return 0 end
            local text = hotbar.Main.Yen.Text
            if string.find(text, "inf") then return math.huge end
            return tonumber(string.gsub(text, "%D", "")) or 0
        end

        -- Расстановка
        local function deployUnit(pos, index)
            if getMoney() < 300 then return false end

            local unitEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent")
            local offset = Vector3.new(math.random(-10, 10)/1000, 0, math.random(-10, 10)/1000)
            local finalPos = pos + offset

            pcall(function()
                unitEvent:FireServer("Render", {"Luffo", 39, finalPos, 0})
                task.wait(0.6)
            end)

            if (game.Workspace:FindFirstChild("Units") and #game.Workspace.Units:GetChildren() >= index) then
                print(`✅ Юнит {index} поставлен`)
                return true
            end
            return false
        end

        local function deployAll()
            if #game.Workspace:FindFirstChild("Units", true):GetChildren() >= 6 then return end
            while getMoney() < 300 do task.wait(1) end
            for i, pos in ipairs(TARGET_POSITIONS) do
                deployUnit(pos, i)
                randomDelay(0.8, 1.5)
            end
        end

        -- 🔁 СБОР ПРЕДМЕТОВ
        local collectedItems = {}  -- Сбрасывается каждый матч

        local function resetItems()
            collectedItems = {}
        end

        local function processItem(child)
            if child.Name ~= "ItemTemplate" or child:GetAttribute("ProcessedAt") then return end
            child:SetAttribute("ProcessedAt", tick())

            task.delay(0.05, function()
                pcall(function()
                    local itemFrame = child:FindFirstChild("ItemFrame")
                    local main = itemFrame and itemFrame:FindFirstChild("Main")
                    local nameObj = main and main:FindFirstChild("ItemName")
                    local amountObj = main and main:FindFirstChild("ItemAmount")
                    if not (nameObj and amountObj) then return end

                    local name = tostring(nameObj.Text)
                    local amountText = tostring(amountObj.Text)
                    local amount = tonumber(string.match(amountText, "%d+")) or 1

                    if not collectedItems[name] then
                        collectedItems[name] = 0
                    end
                    collectedItems[name] += amount

                    print(`📥 +{amount} {name}`)
                end)
            end)
        end

        -- Подключаем ко всем и существующим
        local itemNotifications = playerGui:WaitForChild("ItemNotifications", 5)
            :WaitForChild("ItemNotifications", 5)

        itemNotifications.ChildAdded:Connect(processItem)
        for _, child in pairs(itemNotifications:GetChildren()) do
            processItem(child)
        end

        -- 🌐 ОТПРАВКА ВЕБХУКА
        local function sendWebhook()
            task.wait(0.5)

            local main = playerGui:FindFirstChild("EndScreen")?.Holder?.Main
            if not main then return end

            -- Время
            local timeText = main:FindFirstChild("StageStatistics")?.PlayTime?.Amount?.Text or "0:00"

            -- Уровень
            local levelText = playerGui:FindFirstChild("Hotbar")?.Main?.Level?.Level?.Text or "?"

            -- Формируем награду: "Награда" один раз
            local rewards = {}
            for item, total in pairs(collectedItems) do
                table.insert(rewards, `+{total} {item}`)
            end
            local rewardsStr = #rewards > 0 and table.concat(rewards, "\n") or "Ничего"

            -- В нике спойлер
            local spoilerName = `||{player.Name}||`

            local embed = {
                title = "Anime Vanguards",
                description = `[${levelText}] ${spoilerName}`,
                fields = {
                    {
                        name = "Результат",
                        value = "**Planet Namak (Act1 Normal)**\n⏱️ Время: `" .. timeText .. "`",
                        inline = false
                    },
                    {
                        name = "Награда",
                        value = rewardsStr,
                        inline = false
                    }
                },
                color = 5814783,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
            }

            local data = { embeds = { embed } }
            local url = getgenv().AV_WEBHOOK_URL
            if not url or url == "" then return end

            local http = request or http_request or (http and http.request)
            if not http then return end

            local body = game:GetService("HttpService"):JSONEncode(data)
            local res = http({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })

            if res.StatusCode == 204 then
                print("📤 Вебхук отправлен")
            end
        end

        -- 🔁 ОБРАБОТКА КОНЦА МАТЧА
        playerGui.ChildAdded:Connect(function(child)
            if child.Name == "EndScreen" then
                task.wait(1)
                pcall(sendWebhook)  -- Отправляем
                resetItems()        -- Сбрасываем награды

                task.wait(1)
                pcall(function()
                    game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("EndScreen"):WaitForChild("VoteEvent")
                        :FireServer("Retry")
                end)

                repeat task.wait(0.1) until not child.Parent
                waitForWave()
                deployAll()
                fireSkipWave()
            end
        end)

        -- 🚀 Старт
        fireSkipWave()
        waitForWave()
        deployAll()
    end
end

-- Запуск
pcall(function()
    randomDelay(0.5, 1.5)
    main()
end)

-- Остановка
function stopScript()
    getgenv().AutoUpgradeEnabled = false
    getgenv().MatchRestartEnabled = false
    print("🛑 Скрипт остановлен")
end

print("🟢 Скрипт загружен. Используй stopScript()")
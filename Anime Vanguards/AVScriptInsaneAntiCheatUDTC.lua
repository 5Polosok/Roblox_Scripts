-- 🔒 Безопасная инициализация
if not getgenv then
    return warn("Скрипт работает только в среде с getgenv (Synapse X, Krnl)")
end
if not getgenv().FarmAltsFunpay then return end

-- ⚙️ Глобальные настройки
getgenv().days_amount = 3
getgenv().AutoUpgradeEnabled = true
getgenv().MatchRestartEnabled = true

-- 🔗 Убедись, что установил вебхук!
-- Пример: getgenv().AV_WEBHOOK_URL = "https://discord.com/api/webhooks/..."
if not getgenv().AV_WEBHOOK_URL or getgenv().AV_WEBHOOK_URL == "" then
    warn("⚠️ Вебхук URL не задан! Используй: getgenv().AV_WEBHOOK_URL = '...'")
end

-- 📍 Новые позиции для расстановки юнитов
local TARGET_POSITIONS = {
    Vector3.new(424.83978271484375, 3.7291393280029297, -350.6957702636719),
    Vector3.new(424.9408874511719, 3.7291393280029297, -353.44927978515625),
    Vector3.new(430.9632873535156, 3.7291393280029297, -351.3844299316406),
    Vector3.new(430.8381042480469, 3.7291393280029297, -354.10968017578125),
    Vector3.new(425.84222412109375, 3.7291393280029297, -347.7817687988281),
    Vector3.new(428.85882568359375, 3.7291393280029297, -346.37255859375)
}

-- ⏳ Универсальная случайная задержка
local function randomDelay(min, max)
    local delay = math.random(min * 100, max * 100) / 100
    task.wait(delay)
    return delay
end

-- 🧠 ОСНОВНАЯ ЛОГИКА
local function main()
    local placeId = game.PlaceId
    local player = game:GetService("Players").LocalPlayer

    -- ✅ Анти-афк (через VirtualUser)
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
        -- 🌞 РЕЖИМ: Меню (дейлики, батлпасс, квесты, запуск матча)
        print("🎮 [Меню] Запуск рутины...")

        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player:FindFirstChild("PlayerGui")
        repeat task.wait() until player.PlayerGui:FindFirstChild("Windows")

        -- 1. Выбор начального юнита
        pcall(function()
            local networking = game.ReplicatedStorage:WaitForChild("Networking")
            local selectionEvent = networking:WaitForChild("Units"):WaitForChild("UnitSelectionEvent")
            selectionEvent:FireServer("Select", "Luffo")
            print("✅ Юнит Luffo выбран")
            randomDelay(0.3, 0.7)
        end)

        -- 2. Экипировка первого доступного юнита
        pcall(function()
            local unitsFrame = player.PlayerGui.Windows.Units.Holder.Main.Units
            for _, frame in pairs(unitsFrame:GetChildren()) do
                if frame:IsA("Frame") and frame.Name ~= "BuyMoreSpace" then
                    local equipEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("EquipEvent")
                    equipEvent:FireServer("Equip", frame.Name)
                    print(`✅ Экипирован: {frame.Name}`)
                    break
                end
                randomDelay(0.1, 0.3)
            end
        end)

        -- 3. Получение дейликов
        pcall(function()
            local rewardEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("DailyRewardEvent")
            for _, season in pairs({"Summer", "Spring", "Special"}) do
                for day = 1, getgenv().days_amount do
                    rewardEvent:FireServer("Claim", {season, day})
                    print(`🎁 Получено: {season} — День {day}`)
                    randomDelay(0.2, 0.4)
                end
            end
        end)

        -- 4. Батлпасс
        pcall(function()
            local bpEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("BattlepassEvent")
            bpEvent:FireServer("ClaimAll")
            print("🎖️ Все награды Battlepass получены")
            randomDelay(0.5, 1.2)
        end)

        -- 5. Квесты
        pcall(function()
            local questEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Quests"):WaitForChild("ClaimQuest")
            questEvent:FireServer("ClaimAll")
            print("📜 Все квесты получены")
            randomDelay(0.5, 1.0)
        end)

        -- 6. Создание и запуск матча
        pcall(function()
            local lobbyEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("LobbyEvent")
            lobbyEvent:FireServer("AddMatch", {
                Difficulty = "Normal",
                Act = "Act1",
                StageType = "Story",
                Stage = "Stage1",
                FriendsOnly = true
            })
            print("🎮 Матч добавлен: Act1, Normal")
            randomDelay(0.3, 0.7)

            lobbyEvent:FireServer("StartMatch")
            print("🚀 Матч запущен!")
        end)

        print("✅ Меню-режим завершён. Ожидаем переход в боёвку...")

    elseif placeId == 16277809958 then
        -- 🔥 РЕЖИМ: Боёвка (автопрохождение)
        print("🎮 [Боёвка] Запуск авто-прохождения...")

        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player.Character
        repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")

        -- 🧹 Очистка для повышения FPS
        pcall(function()
            local map = game.Workspace:FindFirstChild("Map")
            if map then
                for _, v in pairs(map:GetChildren()) do
                    if v.Name ~= "Assets" and v.Name ~= "Terrain" then
                        pcall(v.Destroy, v)
                    end
                end
                print("🧹 Очищен Map (оставлены Assets и Terrain)")
            end
        end)

        task.wait(0.5)

        -- ⏭️ Функция: пропустить волну (с повторными попытками)
        local function fireSkipWaveEvent()
            spawn(function()
                local attempts = 0
                while attempts < 5 do
                    pcall(function()
                        local skipEvent = game.ReplicatedStorage:WaitForChild("Networking")
                            :WaitForChild("SkipWaveEvent")
                        skipEvent:FireServer("Skip")
                        print("⏭️ SkipWaveEvent отправлен — волна пропущена")
                        return
                    end)
                    attempts += 1
                    task.wait(1)
                end
                warn("❌ Не удалось отправить SkipWaveEvent после 5 попыток")
            end)
        end

        -- 🧩 ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ

        -- Проверка, активна ли игра
        local function isGameActive()
            local hotbar = player.PlayerGui:FindFirstChild("Hotbar")
            local endScreen = player.PlayerGui:FindFirstChild("EndScreen")
            return hotbar and hotbar.Enabled == true and (not endScreen or not endScreen.Enabled)
        end

        -- Проверка, идёт ли волна
        local function isWaveActive()
            local wave = game.Workspace:FindFirstChild("WaveController")
            return wave and wave:FindFirstChild("CurrentWave") and wave.CurrentWave.Value > 0
        end

        -- Ожидание начала волны
        local function waitForWaveStart()
            print("⏳ Ожидаем начало волны...")
            while getgenv().MatchRestartEnabled do
                if isGameActive() and isWaveActive() then
                    print("🔥 Волна началась!")
                    break
                end
                task.wait(1)
            end
        end

        -- 📊 Получение денег
        local function getPlayerMoney()
            local yenFrame = player.PlayerGui:FindFirstChild("Hotbar")
            if not yenFrame then return 0 end

            local text = yenFrame.Main.Yen.Text
            if not text or string.lower(text):find("inf") then return math.huge end

            local cleanText = string.gsub(text, "%D", "")
            local money = tonumber(cleanText) or 0
            return money
        end

        -- 🔍 Проверка количества юнитов
        local function getUnitCount()
            local units = game.Workspace:FindFirstChild("Units")
            if not units then return 0 end
            return #units:GetChildren()
        end

        -- ✅ ТОЧНАЯ проверка: стоит ли юнит на позиции
        local function isUnitAtExactPosition(position, tolerance)
            local units = game.Workspace:FindFirstChild("Units")
            if not units then return false end

            for _, unit in pairs(units:GetChildren()) do
                local hrp = unit:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - position).Magnitude
                    if dist <= tolerance then
                        return true, unit
                    end
                end
            end
            return false, nil
        end

        -- 🚶‍♂️ Движение к позиции
        local function moveToPosition(targetPosition)
            local char = player.Character
            if not char then return end

            local humanoid = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then return end

            local offset = Vector3.new(
                math.random(-15, 15) / 10,
                0,
                math.random(-15, 15) / 10
            )
            local finalPos = targetPosition + offset

            humanoid:MoveTo(finalPos)

            local startTime = tick()
            repeat task.wait(0.1) until
                (hrp.Position - finalPos).Magnitude < 5 or
                tick() - startTime > 3
        end

        -- 🛠️ Расстановка одного юнита с малым оффсетом
        local function deployUnit(pos, index)
            local unitEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent")
            if not unitEvent then return false end

            local playerMoney = getPlayerMoney()
            if playerMoney < 300 then
                print(`❌ Недостаточно денег для юнита {index} (нужно: 300, есть: {playerMoney})`)
                return false
            end

            local occupied, unitAtPos = isUnitAtExactPosition(pos, 1.8)
            if occupied then
                print(`📍 Позиция {index} занята: {unitAtPos.Name}`)
                return true
            end

            local offsetRange = math.random(3, 10) / 1000
            local offsetX = offsetRange * (math.random(0, 1) * 2 - 1)
            local offsetZ = offsetRange * (math.random(0, 1) * 2 - 1)
            local offsetPos = pos + Vector3.new(offsetX, 0, offsetZ)

            pcall(function()
                unitEvent:FireServer("Render", {"Luffo", 39, offsetPos, 0})
                task.wait(0.6)
            end)

            if isUnitAtExactPosition(offsetPos, 2.0) then
                print(`✅ Юнит {index} поставлен (оффсет)`)
                moveToPosition(offsetPos)
                task.wait(0.5)
                return true
            end

            print(`🔁 [2] Точная позиция`)
            pcall(function()
                unitEvent:FireServer("Render", {"Luffo", 39, pos, 0})
                task.wait(0.6)
            end)

            if isUnitAtExactPosition(pos, 2.0) then
                print(`✅ Юнит {index} поставлен (точно)`)
                moveToPosition(pos)
                task.wait(0.5)
                return true
            end

            local flippedPos = pos - Vector3.new(offsetX, 0, offsetZ)
            print(`🔄 [3] Обратный оффсет: {string.format("%.4f, %.4f", flippedPos.X, flippedPos.Z)}`)
            pcall(function()
                unitEvent:FireServer("Render", {"Luffo", 39, flippedPos, 0})
                task.wait(0.6)
            end)

            if isUnitAtExactPosition(flippedPos, 2.0) then
                print(`✅ Юнит {index} поставлен (обратный оффсет)`)
                moveToPosition(flippedPos)
                task.wait(0.5)
                return true
            end

            warn(`❌ Не удалось поставить юнит {index} после 3 попыток`)
            return false
        end

        -- 🚀 Расстановка всех юнитов
        local function deployAllUnits()
            print("📦 Размещаем юнитов...")
            randomDelay(1, 2)

            local unitCount = getUnitCount()
            if unitCount >= 6 then
                print("🛑 Уже 6 юнитов — больше не ставим")
                return
            end

            while getPlayerMoney() < 300 do
                print(`⏳ Ожидание 300¥ для постановки... (есть: {getPlayerMoney()})`)
                task.wait(2)
            end

            for i, pos in ipairs(TARGET_POSITIONS) do
                local success = deployUnit(pos, i)
                if success then
                    randomDelay(0.8, 1.5)
                else
                    print(`❌ Не удалось поставить юнит {i}`)
                    randomDelay(1.5, 2.0)
                end
            end

            print("✅ Все юниты размещены или попытка выполнена")
        end

        -- 🧠 Хранение уровней юнитов
        local unitLevels = {}

        -- 🔧 Апгрейд: через RemoteEvent
        local function upgradeCheapestUnit()
            if not getgenv().AutoUpgradeEnabled then return end

            local unitCount = getUnitCount()
            if unitCount == 0 or unitCount < 6 then
                print(`🟡 Юнитов: {unitCount}/6 — ставим недостающих...`)
                deployAllUnits()
                return
            end

            local currentMoney = getPlayerMoney()
            local units = game.Workspace:FindFirstChild("Units")
            if not units then return end

            local upgradableUnits = {}
            for _, unit in pairs(units:GetChildren()) do
                if not unit:FindFirstChild("HumanoidRootPart") then continue end

                local unitName = unit.Name
                local level = unitLevels[unitName] or 1

                local nextCost = nil
                if level == 1 then nextCost = 250
                elseif level == 2 then nextCost = 400
                elseif level == 3 then nextCost = 650
                elseif level == 4 then nextCost = 900
                end

                if nextCost and currentMoney >= nextCost then
                    table.insert(upgradableUnits, {
                        unit = unit,
                        name = unitName,
                        level = level,
                        cost = nextCost
                    })
                end
            end

            table.sort(upgradableUnits, function(a, b)
                return a.level < b.level
            end)

            for _, data in ipairs(upgradableUnits) do
                local needed = data.cost
                while currentMoney < needed do
                    print(`⏳ Ждём денег для апгрейда {data.name} (уровень {data.level} → {data.level+1}, нужно: {needed}, есть: {currentMoney})`)
                    task.wait(2)
                    currentMoney = getPlayerMoney()
                end

                print(`🔧 Апгрейдим {data.name}: уровень {data.level} → {data.level+1} за {needed}¥`)
                local unitEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent")
                unitEvent:FireServer("Upgrade", data.name)
                task.wait(0.5)

                unitLevels[data.name] = (unitLevels[data.name] or 1) + 1

                local hrp = data.unit:FindFirstChild("HumanoidRootPart")
                if hrp then
                    moveToPosition(hrp.Position)
                    task.wait(0.5)
                end

                break
            end
        end

        -- 🌐 Отправка результата матча в Discord
        local function sendMatchResult()
            -- Ждём немного, чтобы UI загрузился
            task.wait(0.5)

            local endScreen = player.PlayerGui:FindFirstChild("EndScreen")
            if not endScreen then
                warn("❌ EndScreen не найден")
                return
            end

            local holder = endScreen:FindFirstChild("Holder")
            if not holder then
                warn("❌ Holder не найден в EndScreen")
                return
            end

            local main = holder:FindFirstChild("Main")
            if not main then
                warn("❌ Main не найден в Holder")
                return
            end

            -- 🕐 Время
            local stageStats = main:FindFirstChild("StageStatistics")
            local playTime = stageStats and stageStats:FindFirstChild("PlayTime")
            local timeText = (playTime and playTime:FindFirstChild("Amount") and playTime.Amount.Text) or "0:00"

            -- 🎁 Награды
            local inventoryTemplate = main:FindFirstChild("InventoryTemplate")
            if not inventoryTemplate then
                warn("❌ InventoryTemplate не найден")
                return
            end

            local rewards = {}
            for _, reward in pairs(inventoryTemplate:GetChildren()) do
                if reward:IsA("Frame") and reward.Name ~= "BuyMoreSpace" then
                    local nameLabel = reward:FindFirstChild("Name")
                    local amountLabel = reward:FindFirstChild("Amount")
                    if nameLabel and amountLabel then
                        table.insert(rewards, {
                            name = tostring(nameLabel.Text),
                            amount = tonumber(amountLabel.Text) or 0
                        })
                    end
                end
            end

            -- 🔢 Уровень
            local levelText = "Unknown"
            local hotbar = player.PlayerGui:FindFirstChild("Hotbar")
            if hotbar and hotbar.Main and hotbar.Main.Level and hotbar.Main.Level.Level then
                levelText = hotbar.Main.Level.Level.Text
            end

            -- 🧾 Embed
            local embed = {
                title = "Anime Vanguards",
                description = "[" .. levelText .. "] " .. player.Name,
                fields = {
                    {
                        name = "Result",
                        value = "**Planet Namak (Act1 Normal)**\n⏱️ Time: `" .. timeText .. "`",
                        inline = false
                    }
                },
                color = 5814783,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z") -- ✅ ISO 8601
            }

            for _, r in pairs(rewards) do
                if r.amount > 0 then
                    table.insert(embed.fields, {
                        name = "Reward",
                        value = "+" .. r.amount .. " " .. r.name,
                        inline = true
                    })
                end
            end

            local data = { embeds = { embed } }

            -- 🔗 Проверка URL
            local webhookUrl = getgenv().AV_WEBHOOK_URL
            if not webhookUrl or webhookUrl == "" then
                warn("❌ Вебхук URL не задан! Установи: getgenv().AV_WEBHOOK_URL = 'https://...'")
                return
            end

            -- 🔧 Выбор request
            local httpRequest = request or http_request or (http and http.request) or nil
            if not httpRequest then
                warn("❌ Не найдена функция request. Попробуй Synapse X / Krnl / CC")
                return
            end

            -- 📦 JSON
            local success, body = pcall(game:GetService("HttpService").JSONEncode, game:GetService("HttpService"), data)
            if not success then
                warn("❌ Ошибка JSON:", body)
                return
            end

            -- 📤 Отправка
            local response
            success, response = pcall(function()
                return httpRequest({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body
                })
            end)

            if success then
                if response.StatusCode == 204 then
                    print("📤 Вебхук отправлен в Discord")
                else
                    warn("⚠️ Вебхук отправлен, но статус:", response.StatusCode)
                end
            else
                warn("❌ Ошибка отправки:", response or "неизвестно")
                warn("🔗 URL:", webhookUrl)
            end
        end

        -- 🔁 ЦИКЛЫ

        -- Апгрейд
        coroutine.wrap(function()
            while getgenv().AutoUpgradeEnabled do
                if isGameActive() then
                    upgradeCheapestUnit()
                end
                task.wait(1.0, 1.8)
            end
        end)()

        -- Обработка завершения матча
        coroutine.wrap(function()
            while getgenv().MatchRestartEnabled do
                player.PlayerGui.ChildAdded:Connect(function(child)
                    if child.Name == "EndScreen" then
                        print("🔚 Матч завершён. Отправляем вебхук...")

                        -- Отправляем вебхук
                        task.delay(0.2, function()
                            pcall(sendMatchResult)
                        end)

                        -- Голосуем за ретрай
                        task.delay(0.5, function()
                            pcall(function()
                                local voteEvent = game.ReplicatedStorage:WaitForChild("Networking")
                                    :WaitForChild("EndScreen")
                                    :WaitForChild("VoteEvent")
                                voteEvent:FireServer("Retry")
                                print("🗳️ Голосуем за реплей")
                            end)
                        end)

                        -- Ждём исчезновения экрана
                        repeat task.wait(0.1) until not child.Parent

                        randomDelay(3, 5)
                        fireSkipWaveEvent()
                        randomDelay(8, 12)
                        waitForWaveStart()
                        deployAllUnits()
                    end
                end)
                task.wait(1)
            end
        end)()

        -- 🚀 СТАРТ
        print("🔥 Инициализация скрипта в боёвке...")
        fireSkipWaveEvent()
        waitForWaveStart()
        deployAllUnits()

        print("✅ Автоматизация запущена")

    else
        warn("❌ Неподдерживаемая игра:", placeId)
        return
    end
end

-- 🛡️ Запуск с обработкой ошибок
pcall(function()
    randomDelay(0.5, 1.5)
    main()
end)

-- 🛑 Функция остановки
function stopScript()
    getgenv().AutoUpgradeEnabled = false
    getgenv().MatchRestartEnabled = false
    print("🛑 Скрипт остановлен")
end

-- 📱 Кнопка 3D Rendering
coroutine.wrap(function()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    if not pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(true) end) then
        warn("⚠️ Set3dRenderingEnabled не поддерживается")
        return
    end

    local button = Instance.new("TextButton")
    button.Name = "Toggle3DButton"
    button.Text = "3D: ON"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.new(0, 0.5, 0)
    button.Size = UDim2.new(0, 120, 0, 40)
    button.Position = UDim2.new(0.8, 0, 0.9, 0)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Visible = true
    button.Active = true
    button.ZIndex = 10
    button.Parent = playerGui

    local isEnabled = true
    button.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        game:GetService("RunService"):Set3dRenderingEnabled(isEnabled)
        button.Text = "3D: " .. (isEnabled and "ON" or "OFF")
        button.BackgroundColor3 = isEnabled and Color3.new(0, 0.5, 0) or Color3.new(0.7, 0, 0)
        print(`🎮 3D Rendering: {isEnabled and "ВКЛ" or "ВЫКЛ"}`)
    end)

    player.CharacterAdded:Connect(function()
        if button and not button.Parent then
            button:Destroy()
        end
    end)

    print("📱 Кнопка '3D Rendering' добавлена")
end)()

print("🟢 Скрипт загружен. Используй stopScript(), чтобы остановить.")
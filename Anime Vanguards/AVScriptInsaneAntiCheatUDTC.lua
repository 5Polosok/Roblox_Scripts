-- 🔒 Безопасная инициализация
if not getgenv then
    return warn("Скрипт работает только в среде с getgenv (Synapse X, Krnl)")
end
if not getgenv().AVKaitun then return end

-- ⚙️ Глобальные настройки
getgenv().days_amount = 3
getgenv().AutoUpgradeEnabled = true
getgenv().MatchRestartEnabled = true

-- 🌐 Discord Webhook URL (замени на свой)

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
            local networking = game.ReplicatedStorage:WaitForChild("Networking", 10)
            local selectionEvent = networking:WaitForChild("Units"):WaitForChild("UnitSelectionEvent", 5)
            selectionEvent:FireServer("Select", "Luffo")
            print("✅ Юнит Luffo выбран")
            randomDelay(0.3, 0.7)
        end)

        -- 2. Экипировка первого доступного юнита
        pcall(function()
            local unitsFrame = player.PlayerGui.Windows.Units.Holder.Main.Units
            for _, frame in pairs(unitsFrame:GetChildren()) do
                if frame:IsA("Frame") and frame.Name ~= "BuyMoreSpace" then
                    local equipEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("EquipEvent", 5)
                    equipEvent:FireServer("Equip", frame.Name)
                    print(`✅ Экипирован: {frame.Name}`)
                    break
                end
                randomDelay(0.1, 0.3)
            end
        end)

        -- 3. Получение дейликов
        pcall(function()
            local rewardEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("DailyRewardEvent", 5)
            if rewardEvent then
                for _, season in pairs({"Summer", "Spring", "Special"}) do
                    for day = 1, getgenv().days_amount do
                        rewardEvent:FireServer("Claim", {season, day})
                        print(`🎁 Получено: {season} — День {day}`)
                        randomDelay(0.2, 0.4)
                    end
                end
            end
        end)

        -- 4. Батлпасс
        pcall(function()
            local bpEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("BattlepassEvent", 5)
            if bpEvent then
                bpEvent:FireServer("ClaimAll")
                print("🎖️ Все награды Battlepass получены")
                randomDelay(0.5, 1.2)
            end
        end)

        -- 5. Квесты
        pcall(function()
            local questEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Quests"):WaitForChild("ClaimQuest", 5)
            if questEvent then
                questEvent:FireServer("ClaimAll")
                print("📜 Все квесты получены")
                randomDelay(0.5, 1.0)
            else
                warn("❌ ClaimQuest не найден")
            end
        end)

        -- 6. Создание и запуск матча
        pcall(function()
            local lobbyEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("LobbyEvent", 5)
            if lobbyEvent then
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
            end
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

        -- ⏭️ Функция: пропустить волну
        local function fireSkipWaveEvent()
            pcall(function()
                local skipEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("SkipWaveEvent", 5)
                if skipEvent then
                    skipEvent:FireServer("Skip")
                    print("⏭️ SkipWaveEvent отправлен — волна пропущена")
                else
                    warn("❌ SkipWaveEvent не найден")
                end
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
            if not text or text:lower():find("inf") then return math.huge end

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
            local unitEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent", 5)
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
                print(`🚚 [1] Оффсет: {string.format("%.4f, %.4f", offsetPos.X, offsetPos.Z)}`)
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
            unitLevels = {} -- 🔁 Сброс уровней
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
        local MAX_LEVEL = 5

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

                unitLevels[data.name] = data.level + 1

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
            local endScreen = player.PlayerGui:FindFirstChild("EndScreen")
            if not endScreen then return end

            local holder = endScreen:FindFirstChild("Holder")
            if not holder then return end

            local main = holder:FindFirstChild("Main")
            if not main then return end

            local stageStats = main:FindFirstChild("StageStatistics")
            if not stageStats then return end

            local playTime = stageStats:FindFirstChild("PlayTime")
            local timeText = playTime and playTime.Amount.Text or "0:00"

            local inventoryTemplate = main:FindFirstChild("InventoryTemplate")
            if not inventoryTemplate then return end

            local rewards = {}
            for _, reward in pairs(inventoryTemplate:GetChildren()) do
                if reward:IsA("Frame") and reward.Name ~= "BuyMoreSpace" then
                    local nameLabel = reward:FindFirstChild("Name")
                    local amountLabel = reward:FindFirstChild("Amount")
                    if nameLabel and amountLabel then
                        table.insert(rewards, {
                            name = nameLabel.Text,
                            amount = tonumber(amountLabel.Text) or 0
                        })
                    end
                end
            end

            -- Формирование вебхука
            local levelText = player.PlayerGui.Hotbar.Main.Level.Level.Text
            local embed = {
                title = "Anime Vanguards",
                fields = {
                    { name = "Name", value = `[${levelText}] ${player.Name}`, inline = false },
                    { name = "Result", value = `Planet Namak (Act1 Normal) - Finished\n- Time: ${timeText}\n- Reward:`, inline = false }
                },
                color = 5814783,
                timestamp = DateTime.now():ToIsoDate()
            }

            for _, r in pairs(rewards) do
                table.insert(embed.fields, { name = "", value = `+${r.amount} ${r.name}`, inline = false })
            end

            local data = { embeds = { embed } }
            local request = request or http_request or http.request
            local body = game:GetService("HttpService"):JSONEncode(data)
            pcall(function()
                request({
                    Url = getgenv().AV_WEBHOOK_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body
                })
            end)
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

        -- Рестарт + вебхук
        coroutine.wrap(function()
            while getgenv().MatchRestartEnabled do
                local endScreen = player.PlayerGui:FindFirstChild("EndScreen")
                if endScreen and endScreen.Enabled then
                    print("🔚 Матч завершён. Перезапускаем...")

                    pcall(function()
                        game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("EndScreen"):WaitForChild("VoteEvent"):FireServer("Retry")
                        print("🗳️ Голосуем за реплей")
                    end)

                    randomDelay(3, 5)
                    fireSkipWaveEvent()
                    randomDelay(8, 12)
                    waitForWaveStart()
                    deployAllUnits()

                    -- Отправляем вебхук
                    task.delay(1, sendMatchResult)
                end
                task.wait(2)
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

print("🟢 Скрипт загружен. Используй stopScript(), чтобы остановить.")
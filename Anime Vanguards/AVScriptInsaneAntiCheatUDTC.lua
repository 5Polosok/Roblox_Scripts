-- 🔒 Безопасная инициализация
if not getgenv then
    return warn("Скрипт работает только в среде с getgenv (Synapse X, Krnl)")
end
if not getgenv().FarmAltsFunpay then return end
if getgenv().NoRenderAV == nil then getgenv().NoRenderAV = false end

-- ⚙️ Глобальные настройки
getgenv().days_amount = 7
getgenv().AutoUpgradeEnabled = true
getgenv().MatchRestartEnabled = true

-- 🔗 Убедись, что установил вебхук!
if not getgenv().AV_WEBHOOK_URL or getgenv().AV_WEBHOOK_URL == "" then
    warn("⚠️ Вебхук URL не задан! Используй: getgenv().AV_WEBHOOK_URL = '...'")
end

-- 📍 Позиции для расстановки юнитов в боёвке
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
task.spawn(function()
    setfpscap(30)
end)
-- ⚙️ ОСНОВНАЯ ЛОГИКА
local function main()
    local placeId = game.PlaceId
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui", 10)
    task.spawn(function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/5Polosok/Roblox_Scripts/refs/heads/main/FEscripts/FPSBoost.lua"))()
    end)
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

    -- 📦 Сбор наград из уведомлений
    local collectedItems = {}

    local function resetCollectedItems()
        collectedItems = {}
    end

    local function processItemNotification(child)
        if child.Name ~= "ItemTemplate" or child:GetAttribute("Processed") then return end
        child:SetAttribute("Processed", true)

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

    if placeId == 16146832113 then
        -- 🌞 РЕЖИМ: ЛОББИ (МЕНЮ)

        print("🎮 [Меню] Запуск рутины...")

        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player:FindFirstChild("PlayerGui")
        repeat task.wait() until playerGui:FindFirstChild("Windows")

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
            local unitsFrame = playerGui.Windows.Units.Holder.Main.Units
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
        -- 🔥 РЕЖИМ: БОЁВКА

        print("🎮 [Боёвка] Запуск авто-прохождения...")

        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player.Character
        repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")
        -- 🧹 Оптимизация FPS: Удаление врагов из оригинальной папки
        task.spawn(function()
            local entities = game.Workspace:WaitForChild("Entities", 10)
            if not entities then return end

            for _, child in ipairs(entities:GetChildren()) do
                spawn(child.Destroy, child)
            end

            entities.ChildAdded:Connect(function(child)
                spawn(function()
                    task.wait(0.05)
                    if child and child.Parent == entities then
                        child:Destroy()
                    end
                end)
            end)

            print("🧹 Entities зачищается в реальном времени")
        end)
        -- 🧹 Очистка для FPS
        pcall(function()
            game:GetService("RunService"):Set3dRenderingEnabled(not getgenv().NoRenderAV)
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

        -- ⏭️ Пропуск волны
        local function fireSkipWaveEvent()
            task.spawn(function()
                local attempts = 0
                while attempts < 3 do
                    pcall(function()
                        local skipEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("SkipWaveEvent")
                        skipEvent:FireServer("Skip")
                        print("⏭️ SkipWaveEvent отправлен — волна пропущена")
                        return
                    end)
                    attempts += 1
                    task.wait(1)
                end
                warn("❌ Не удалось отправить SkipWaveEvent после 3 попыток")
            end)
        end

        -- ✅ МОНИТОРИНГ: Пропуск волны ТОЛЬКО когда GUI "SkipWave" активен
        task.spawn(function()
            print("⏳ Ожидание кнопки SkipWave (GUI-триггер)...")
            while getgenv().MatchRestartEnabled do
                local skipGui = playerGui:FindFirstChild("SkipWave")

                if skipGui and skipGui.Enabled == true then
                    print("🎯 Кнопка SkipWave активна — пропускаем волну!")
                    fireSkipWaveEvent()

                    -- Избегаем повторного срабатывания
                    task.wait(3)
                end

                task.wait(1.5) -- Проверка каждые 1.5 сек
            end
        end)

        -- 🧩 ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ

        local function isGameActive()
            local hotbar = playerGui:FindFirstChild("Hotbar")
            local endScreen = playerGui:FindFirstChild("EndScreen")
            return hotbar and hotbar.Enabled == true and (not endScreen or not endScreen.Enabled)
        end

        local function getPlayerMoney()
            local yenFrame = playerGui:FindFirstChild("Hotbar")
            if not yenFrame then return 0 end

            local text = yenFrame.Main.Yen.Text
            if not text or string.lower(text):find("inf") then return math.huge end

            local cleanText = string.gsub(text, "%D", "")
            local money = tonumber(cleanText) or 0
            return money
        end

        local function getUnitCount()
            local units = game.Workspace:FindFirstChild("Units")
            if not units then return 0 end
            return #units:GetChildren()
        end

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
                print(`Юнит {index} поставлен (точно)`)
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

        -- 🔧 Апгрейд
        local unitLevels = {}
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

        -- 🌐 Отправка вебхука
        local function sendMatchResult()
            task.wait(0.5)

            local endScreen = playerGui:FindFirstChild("EndScreen")
            if not endScreen then return end

            local holder = endScreen:FindFirstChild("Holder")
            if not holder then return end

            local main = holder:FindFirstChild("Main")
            if not main then return end

            -- 🕐 Время
            local stageStats = main:FindFirstChild("StageStatistics")
            local playTime = stageStats and stageStats:FindFirstChild("PlayTime")
            local timeText = (playTime and playTime:FindFirstChild("Amount") and playTime.Amount.Text) or "0:00"

            -- 🔢 Уровень
            local levelText = "Unknown"
            local hotbar = playerGui:FindFirstChild("Hotbar")
            if hotbar and hotbar.Main and hotbar.Main.Level and hotbar.Main.Level.Level then
                levelText = hotbar.Main.Level.Level.Text
            end

            -- 💎 Атрибуты
            local gems = player:GetAttribute("Gems") or 0
            local gold = player:GetAttribute("Gold") or 0
            local rerolls = player:GetAttribute("TraitRerolls") or 0

            -- 🧾 Embed
            local embed = {
                title = "Anime Vanguards",
                description = "[" .. levelText .. "] ||" .. player.Name .. "||",
                fields = {
                    {
                        name = "Результат",
                        value = "**Planet Namak (Act1 Normal)**\n⏱️ Time: `" .. timeText .. "`",
                        inline = false
                    }
                },
                color = 5814783,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
            }

            -- 📦 Награды из уведомлений
            local rewardsList = {}
            for itemName, total in pairs(collectedItems) do
                table.insert(rewardsList, "+" .. total .. " " .. itemName)
            end

            if #rewardsList > 0 then
                table.insert(embed.fields, {
                    name = "Награда",
                    value = table.concat(rewardsList, "\n"),
                    inline = false
                })
            end

            -- 💰 Баланс
            table.insert(embed.fields, {
                name = "Баланс",
                value = `💎 Gems: {gems}\n💰 Gold: {gold}`,
                inline = false
            })

            -- 🔁 Rerolls
            table.insert(embed.fields, {
                name = "Дополнительно",
                value = `🔄 Trait Rerolls: {rerolls}`,
                inline = false
            })

            local data = { embeds = { embed } }

            -- 🔗 Отправка
            local webhookUrl = getgenv().AV_WEBHOOK_URL
            if not webhookUrl or webhookUrl == "" then return end

            local httpRequest = request or http_request or (http and http.request)
            if not httpRequest then return end

            local success, body = pcall(game:GetService("HttpService").JSONEncode, game:GetService("HttpService"), data)
            if not success then return end

            local success, response = pcall(function()
                return httpRequest({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body
                })
            end)

            if success and response.StatusCode == 204 then
                print("📤 Вебхук отправлен в Discord")
            end
        end

        -- Подключаем сбор уведомлений
        spawn(function()
            repeat task.wait() until playerGui:FindFirstChild("ItemNotifications")
            local notifications = playerGui.ItemNotifications:FindFirstChild("ItemNotifications")
            if notifications then
                notifications.ChildAdded:Connect(processItemNotification)
                for _, child in pairs(notifications:GetChildren()) do
                    processItemNotification(child)
                end
            end
        end)

        -- 🔁 Циклы
        coroutine.wrap(function()
            while getgenv().AutoUpgradeEnabled do
                if isGameActive() then upgradeCheapestUnit() end
                randomDelay(1.0, 1.8)
            end
        end)()

        -- Обработка конца матча
        local lastEndScreen = nil
        playerGui.ChildAdded:Connect(function(child)
            if child.Name == "EndScreen" and child ~= lastEndScreen then
                lastEndScreen = child

                randomDelay(0.8, 1.2)
                pcall(sendMatchResult)
                resetCollectedItems()

                randomDelay(0.8, 1.2)
                pcall(function()
                    local voteEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("EndScreen"):WaitForChild("VoteEvent")
                    voteEvent:FireServer("Retry")
                    print("🗳️ Голосуем за реплей")
                end)

                repeat task.wait(0.1) until not child.Parent
                print("🗑️ Экран завершения закрыт")

                -- Ждём немного перед следующими действиями
                randomDelay(1.0, 2.0)
            end
        end)

        -- 🚀 Старт
        print("✅ Автоматизация запущена")
    else
        warn("❌ Неподдерживаемая игра:", placeId)
    end
end

-- 🛡️ Запуск
pcall(function()
    randomDelay(0.5, 1.5)
    main()
end)

-- 🛑 Остановка
function stopScript()
    getgenv().AutoUpgradeEnabled = false
    getgenv().MatchRestartEnabled = false
    print("🛑 Скрипт остановлен")
end

print("🟢 Скрипт загружен. Используй stopScript(), чтобы остановить.")
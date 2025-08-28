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
if not getgenv().AV_WEBHOOK_URL or getgenv().AV_WEBHOOK_URL == "" then
    warn("⚠️ Вебхук URL не задан! Используй: getgenv().AV_WEBHOOK_URL = '...'")
end

-- 📍 Позиции для расстановки юнитов
local TARGET_POSITIONS = {
    Vector3.new(424.83978271484375, 3.7291393280029297, -350.6957702636719),
    Vector3.new(424.9408874511719, 3.7291393280029297, -353.44927978515625),
    Vector3.new(430.9632873535156, 3.7291393280029297, -351.3844299316406),
    Vector3.new(430.8381042480469, 3.7291393280029297, -354.10968017578125),
    Vector3.new(425.84222412109375, 3.7291393280029297, -347.7817687988281),
    Vector3.new(428.85882568359375, 3.7291393280029297, -346.37255859375)
}

-- ⏳ Случайная задержка
local function randomDelay(min, max)
    local delay = math.random(min * 100, max * 100) / 100
    task.wait(delay)
    return delay
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

    -- 📦 Глобальный счётчик наград
    local collectedItems = {}

    -- 🔁 Сброс наград
    local function resetItems()
        collectedItems = {}
    end

    -- 🧩 Обработка ItemTemplate (награды)
    local function processItem(child)
        if child.Name ~= "ItemTemplate" or child:GetAttribute("Processed") then return end
        child:SetAttribute("Processed", true)

        task.delay(0.05, function()
            pcall(function()
                local itemFrame = child:FindFirstChild("ItemFrame")
                if not itemFrame then return end

                local main = itemFrame:FindFirstChild("Main")
                if not main then return end

                local nameObj = main:FindFirstChild("ItemName")
                local amountObj = main:FindFirstChild("ItemAmount")
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
        -- 🌞 МЕНЮ РЕЖИМ
        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player:FindFirstChild("PlayerGui")
        repeat task.wait() until playerGui:FindFirstChild("Windows")

        -- 1. Выбор юнита
        pcall(function()
            local selectionEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("UnitSelectionEvent")
            selectionEvent:FireServer("Select", "Luffo")
            print("✅ Юнит Luffo выбран")
            randomDelay(0.3, 0.7)
        end)

        -- 2. Экипировка
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

        -- 3. Дейлики
        pcall(function()
            local rewardEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("DailyRewardEvent")
            for _, season in {"Summer", "Spring", "Special"} do
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

        -- 6. Запуск матча
        pcall(function()
            local lobbyEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("LobbyEvent")
            lobbyEvent:FireServer("AddMatch", {
                Difficulty = "Normal",
                Act = "Act1",
                StageType = "Story",
                Stage = "Stage1",
                FriendsOnly = true
            })
            randomDelay(0.3, 0.7)
            lobbyEvent:FireServer("StartMatch")
            print("🚀 Матч запущен!")
        end)

        print("✅ Меню-режим завершён. Ожидаем переход в боёвку...")

    elseif placeId == 16277809958 then
        -- 🔥 БОЁВКА

        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player.Character
        repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")

        -- 🧹 Очистка карты
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

        -- ⏭️ Пропуск волны
        local function fireSkipWaveEvent()
            spawn(function()
                for i = 1, 3 do
                    pcall(function()
                        local skipEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("SkipWaveEvent")
                        skipEvent:FireServer("Skip")
                        print("⏭️ SkipWaveEvent отправлен — волна пропущена")
                        return
                    end)
                    task.wait(1)
                end
                warn("❌ Не удалось отправить SkipWaveEvent после 3 попыток")
            end)
        end

        -- ✅ Проверка активности
        local function isGameActive()
            local hotbar = playerGui:FindFirstChild("Hotbar")
            local endScreen = playerGui:FindFirstChild("EndScreen")
            return hotbar and hotbar.Enabled == true and (not endScreen or not endScreen.Enabled)
        end

        -- ✅ Проверка волны (через GUI)
        local function isWaveActive()
            local hud = playerGui:FindFirstChild("HUD")
            if not hud then return false end

            local wavesFrame = hud:FindFirstChild("Map")
            if not wavesFrame then return false end

            local contentTextObj = wavesFrame:FindFirstChild("WavesAmount")
            if not contentTextObj then return false end

            local contentText = contentTextObj:FindFirstChild("ContentText")
            if not contentText or not contentText.Text then return false end

            local currentWave = tonumber((string.split(contentText.Text, "/"))[1]) or 0
            return currentWave > 0
        end

        -- ✅ Ожидание волны
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

        -- 💰 Деньги
        local function getPlayerMoney()
            local yenFrame = playerGui:FindFirstChild("Hotbar")
            if not yenFrame then return 0 end

            local text = yenFrame.Main.Yen.Text
            if not text or string.lower(text):find("inf") then return math.huge end

            local cleanText = string.gsub(text, "%D", "")
            return tonumber(cleanText) or 0
        end

        -- 🔍 Кол-во юнитов
        local function getUnitCount()
            local units = game.Workspace:FindFirstChild("Units")
            return units and #units:GetChildren() or 0
        end

        -- ✅ Точная проверка позиции
        local function isUnitAtExactPosition(position, tolerance)
            local units = game.Workspace:FindFirstChild("Units")
            if not units then return false end

            for _, unit in pairs(units:GetChildren()) do
                local hrp = unit:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - position).Magnitude <= tolerance then
                    return true, unit
                end
            end
            return false
        end

        -- 🚶 Движение
        local function moveToPosition(pos)
            local char = player.Character
            if not char then return end

            local humanoid = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then return end

            humanoid:MoveTo(pos + Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
            local start = tick()
            repeat task.wait(0.1) until (hrp.Position - pos).Magnitude < 5 or tick() - start > 3
        end

        -- 🛠️ Постановка юнита (3 попытки)
        local function deployUnit(pos, index)
            local unitEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent")
            if getPlayerMoney() < 300 then return false end

            if isUnitAtExactPosition(pos, 1.8) then return true end

            local offset = Vector3.new(
                (math.random(3,10)/1000) * (math.random(0,1)*2-1),
                0,
                (math.random(3,10)/1000) * (math.random(0,1)*2-1)
            )

            for _, offsetPos in pairs({pos + offset, pos, pos - offset}) do
                pcall(function()
                    unitEvent:FireServer("Render", {"Luffo", 39, offsetPos, 0})
                    task.wait(0.6)
                end)

                if isUnitAtExactPosition(offsetPos, 2.0) then
                    moveToPosition(offsetPos)
                    task.wait(0.5)
                    return true
                end
            end

            warn(`❌ Не удалось поставить юнит {index}`)
            return false
        end

        -- 🚀 Расстановка всех
        local function deployAllUnits()
            if getUnitCount() >= 6 then return end
            while getPlayerMoney() < 300 do task.wait(1) end

            for i, pos in ipairs(TARGET_POSITIONS) do
                deployUnit(pos, i)
                randomDelay(0.8, 1.5)
            end
        end

        -- 🔧 Апгрейд
        local unitLevels = {}
        local function upgradeCheapestUnit()
            if not getgenv().AutoUpgradeEnabled or getUnitCount() < 6 then return end

            local currentMoney = getPlayerMoney()
            local units = game.Workspace:FindFirstChild("Units")
            if not units then return end

            local upgradable = {}
            for _, unit in pairs(units:GetChildren()) do
                if not unit:FindFirstChild("HumanoidRootPart") then continue end

                local name = unit.Name
                local level = unitLevels[name] or 1
                local cost = {250, 400, 650, 900}[level]

                if cost and currentMoney >= cost then
                    table.insert(upgradable, {name = name, level = level, cost = cost})
                end
            end

            table.sort(upgradable, function(a,b) return a.level < b.level end)

            for _, u in ipairs(upgradable) do
                while getPlayerMoney() < u.cost do task.wait(1) end

                game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent")
                    :FireServer("Upgrade", u.name)
                unitLevels[u.name] = (unitLevels[u.name] or 1) + 1
                task.wait(0.5)
                break
            end
        end

        -- 🌐 Вебхук
        local function sendMatchResult()
            task.wait(1)

            local main = playerGui:FindFirstChild("EndScreen")?.Holder?.Main
            if not main then return end

            -- Время
            local timeText = main:FindFirstChild("StageStatistics")?.PlayTime?.Amount?.Text or "0:00"
            -- Уровень
            local levelText = playerGui:FindFirstChild("Hotbar")?.Main?.Level?.Level?.Text or "?"

            -- Атрибуты
            local gems = player:GetAttribute("Gems") or 0
            local gold = player:GetAttribute("Gold") or 0
            local rerolls = player:GetAttribute("TraitRerolls") or 0

            -- Награды
            local rewards = {}
            for item, total in pairs(collectedItems) do
                table.insert(rewards, `+{total} {item}`)
            end

            local embed = {
                title = "Anime Vanguards",
                description = `[${levelText}] ||${player.Name}||`,
                fields = {
                    { name = "Результат", value = "**Planet Namak (Act1 Normal)**\n⏱️ Time: `"..timeText.."`", inline = false },
                    (#rewards > 0) and { name = "Награда", value = table.concat(rewards, "\n"), inline = false } or nil,
                    { name = "Баланс", value = `💎 Gems: {gems}\n💰 Gold: {gold}`, inline = false },
                    { name = "Дополнительно", value = `🔄 Trait Rerolls: {rerolls}`, inline = false }
                },
                color = 5814783,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
            }

            -- Убираем nil
            local filteredFields = {}
            for _, f in pairs(embed.fields) do if f then table.insert(filteredFields, f) end end
            embed.fields = filteredFields

            local data = { embeds = { embed } }
            local url = getgenv().AV_WEBHOOK_URL
            if not url then return end

            local http = request or http_request or (http and http.request)
            if not http then return end

            local body = game:GetService("HttpService"):JSONEncode(data)
            local _, res = pcall(http, {
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })

            if res and res.StatusCode == 204 then
                print("📤 Вебхук отправлен")
            end
        end

        -- Подключаем сбор предметов
        spawn(function()
            repeat task.wait() until playerGui:FindFirstChild("ItemNotifications")
            local notifications = playerGui.ItemNotifications:FindFirstChild("ItemNotifications")
            if notifications then
                notifications.ChildAdded:Connect(processItem)
                for _, child in pairs(notifications:GetChildren()) do
                    processItem(child)
                end
            end
        end)

        -- 🔁 Циклы
        coroutine.wrap(function()
            while getgenv().AutoUpgradeEnabled do
                if isGameActive() then upgradeCheapestUnit() end
                task.wait(1.0, 1.8)
            end
        end)()

        -- Конец матча
        local lastEndScreen = nil
        playerGui.ChildAdded:Connect(function(child)
            if child.Name == "EndScreen" and child ~= lastEndScreen then
                lastEndScreen = child

                task.wait(1)
                pcall(sendMatchResult)
                resetItems()

                task.wait(1)
                pcall(function()
                    game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("EndScreen"):WaitForChild("VoteEvent")
                        :FireServer("Retry")
                end)

                repeat task.wait(0.1) until not child.Parent
                waitForWaveStart()
                deployAllUnits()
                fireSkipWaveEvent()
            end
        end)

        -- 🚀 Старт
        fireSkipWaveEvent()
        waitForWaveStart()
        deployAllUnits()
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

print("🟢 Скрипт загружен. Используй stopScript(), чтобы остановить.")
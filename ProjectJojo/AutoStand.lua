-- 🔧 НАСТРОЙКА: Список Stand'ов, которые НЕЛЬЗЯ прокручивать (protected)
getgenv().protected_stands = getgenv().protected_stands or {
    "gold", "wonder", "tusk", "d4"
}
getgenv().if_send_webhook = {
    "gold", "wonder", "tusk", "d4", "cream", "star", "world", "whitesnake", "kingcrimson", "killerqueen"
}

-- 🔍 Проверка: является ли Stand нужным
local function isProtectedStand(standName)
    if standName == "None" then return false end
    local lower = string.lower(standName)
    for _, protected in ipairs(getgenv().protected_stands) do
        if string.find(lower, protected) then
            return true
        end
    end
    return false
end

-- 🧩 Основные сервисы
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- 🔧 Вебхук
getgenv().webhook_url_autostand = getgenv().webhook_url or "ВАШ_ВЕБХУК_ЗДЕСЬ"

-- 🔧 Включить/выключить уведомления
getgenv().enable_webhook = getgenv().enable_webhook ~= false

-- Remote события
local fruitevent = ReplicatedStorage.Logic:WaitForChild("fruitevent")
local luckyarrowevent = ReplicatedStorage.Logic:WaitForChild("luckyarrowevent")
local giveitem = ReplicatedStorage.Logic:WaitForChild("giveitem")

-- Флаг: защита от дублирования
local isProcessing = false

-- === Функция: получить актуальные ссылки ===
local function getLatestRefs()
    local character = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack", 10)
    local stand = player:WaitForChild("Stand")
    if not backpack then return nil, nil, nil end
    return character, backpack, stand
end

-- === Утилита: найти инструмент ===
local function findTool(name)
    local character, backpack = getLatestRefs()
    if not character or not backpack then return nil end
    return character:FindFirstChild(name) or backpack:FindFirstChild(name)
end

-- === Утилита: надеть инструмент ===
local function equipTool(tool)
    if not tool then return end
    local character = player.Character
    if tool.Parent ~= character then
        pcall(function() tool.Parent = character end)
        task.wait(0.3)
    end
end

-- === Получить предмет, если его нет ===
local function ensureItem(itemName)
    if findTool(itemName) then return end
    print("[Предмет] 🚀 Выдаём отсутствующий предмет:", itemName)
    local args = { itemName }
    pcall(function() giveitem:FireServer(unpack(args)) end)
    task.wait(1)
end

-- 🌐 Отправка вебхука в Discord
-- 🌐 Отправка вебхука в Discord (совместимо с эксплойтами)
local function sendWebhook(standName)
    if not getgenv().enable_webhook then return end
    if not getgenv().webhook_url or string.find(getgenv().webhook_url, "webhooks") == nil then
        warn("[Вебхук] ⚠️ Вебхук не настроен или неверный URL.")
        return
    end
    -- Сделать проверку есть ли standName в списке через string.find
    local shouldSend = false
    for _, name in ipairs(getgenv().if_send_webhook) do
        if string.find(string.lower(standName), string.lower(name)) then
            shouldSend = true
            break
        end
    end
    -- Проверка нужно ли отправлять вебхук для этого стенда
    if not shouldSend then
        print("[Вебхук] ℹ️ Stand '" .. standName .. "' не в списке для отправки вебхука. Пропускаем.")
        return
    end
    -- Проверка: доступен ли http_request (эксплойт)
    if not http_request and not syn and not request then
        warn("[Вебхук] ❌ Нет доступа к HTTP-запросам. Используй эксплойт (Synapse, KRNL и т.д.).")
        return
    end

    local embed = {
        title = "🔥 Project JOJO",
        description = "**" .. player.Name .. "** получил способность!",
        fields = {{
            name = "🎯 Полученный стенд",
            value = "```" .. standName .. "```",
            inline = false
        }},
        color = 5814783,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        footer = { text = "Project JOJO Auto-System" },
        author = {
            name = "Игрок: " .. player.Name,
            icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
        }
    }

    local data = { embeds = { embed } }
    local body = HttpService:JSONEncode(data)

    -- Определяем, какую функцию использовать
    local httpRequestFunction = http_request or (syn and syn.request) or request

    local success, response = pcall(function()
        return httpRequestFunction({
            Url = getgenv().webhook_url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)

    if success then
        if response and (response.StatusCode == 200 or response.StatusCode == 204) then
            print("[Вебхук] ✅ Уведомление отправлено в Discord.")
        else
            warn("[Вебхук] ❌ Ошибка: код ответа", response and response.StatusCode or "неизвестен")
        end
    else
        warn("[Вебхук] ❌ Ошибка запроса:", response)
    end
end

-- === Сброс Stand'а через RokakakaFruit ===
local function tryResetStand()
    if isProcessing then return end
    local _, _, stand = getLatestRefs()
    if not stand then return end

    if isProtectedStand(stand.Value) then
        print("[Сброс] ⛔ ЗАПРЕЩЕНО: Stand '" .. stand.Value .. "' — защищён.")
        return
    end

    if stand.Value == "None" then return end

    local rokakaka = findTool("RokakakaFruit")
    if not rokakaka then
        print("[Сброс] ❌ RokakakaFruit не найден. Получаем...")
        ensureItem("RokakakaFruit")
        rokakaka = findTool("RokakakaFruit")
        if not rokakaka then return end
    end

    equipTool(rokakaka)
    if rokakaka.Parent ~= player.Character then return end

    isProcessing = true
    print("[Сброс] ✅ Отправляю fruitevent...")
    pcall(function()
        fruitevent:InvokeServer(rokakaka, player.Character, 2)
    end)
    print("[Сброс] 🔔 Команда отправлена.")
    isProcessing = false
end

-- === Получение Stand'а через LuckyStandArrow ===
local function tryObtainStand()
    if isProcessing then return end
    local _, _, stand = getLatestRefs()
    if not stand then return end

    if isProtectedStand(stand.Value) then
        print("[Получение] ⛔ ЗАПРЕЩЕНО: Stand '" .. stand.Value .. "' — защищён.")
        return
    end

    if stand.Value ~= "None" then return end

    local luckyArrow = findTool("LuckyStandArrow")
    if not luckyArrow then
        print("[Получение] ❌ LuckyStandArrow не найден. Получаем...")
        ensureItem("LuckyStandArrow")
        luckyArrow = findTool("LuckyStandArrow")
        if not luckyArrow then return end
    end

    equipTool(luckyArrow)
    if luckyArrow.Parent ~= player.Character then return end

    isProcessing = true
    print("[Получение] ✅ Отправляю luckyarrowevent...")

    -- Сохраняем старое значение
    local oldStand = stand.Value

    pcall(function()
        luckyarrowevent:InvokeServer(luckyArrow, player.Character, 0)
    end)

    -- Через 1.2 сек проверяем, изменился ли Stand
    task.delay(1.2, function()
        if stand.Value ~= "None" and stand.Value ~= oldStand and not isProtectedStand(stand.Value) then
            print("[Вебхук] 🎉 Новый стенд получен: " .. stand.Value)
            sendWebhook(stand.Value)
        end
    end)

    print("[Получение] 🔔 Команда отправлена.")
    isProcessing = false
end

-- === Главная функция ===
local function onCharacterReady()
    print("[Скрипт] 🔁 Персонаж и инвентарь загружены.")
    task.delay(1.5, function()
        tryResetStand()
        task.delay(0.5, tryObtainStand)
    end)
end

-- === Обработчик изменения Stand.Value ===
player.Stand.Changed:Connect(function()
    task.spawn(function()
        task.wait(0.3)
        local _, _, stand = getLatestRefs()
        if not stand then return end

        if isProtectedStand(stand.Value) then
            print("[Event] ⛔ Stand защищён: " .. stand.Value)
            return
        end

        if stand.Value == "None" then
            print("[Event] 🔄 Stand сброшен — можно получить новый.")
            task.delay(1.5, tryObtainStand)
        end
    end)
end)

-- === Запуск ===
onCharacterReady()

-- === После респауна ===
player.CharacterAdded:Connect(function()
    isProcessing = false
    print("[Респ] 🆕 Новый персонаж. Перезагрузка...")
    task.wait(1)
    onCharacterReady()
end)
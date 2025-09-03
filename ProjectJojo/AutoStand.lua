-- 🔧 НАСТРОЙКА: Список Stand'ов, которые НЕЛЬЗЯ прокручивать (protected)
getgenv().protected_stands = getgenv().protected_stands or {
    "gold", "wonder", "tusk", "d4"
}
getgenv().if_send_webhook = {
    "gold", "wonder", "tusk", "d4c", "cream", "starplatinum", "theworld", "whitesnake", "kingcrimson", "killerqueen"
}

-- 🔍 Проверка: является ли Stand защищённым
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
getgenv().webhook_url_autostand = getgenv().webhook_url_autostand or "ВАШ_ВЕБХУК_ЗДЕСЬ"
getgenv().enable_webhook = getgenv().enable_webhook ~= false

-- 🔌 Remote события
local fruitevent = ReplicatedStorage.Logic:WaitForChild("fruitevent")
local luckyarrowevent = ReplicatedStorage.Logic:WaitForChild("luckyarrowevent")
local giveitem = ReplicatedStorage.Logic:WaitForChild("giveitem")

-- 🔒 Флаг: защита от дублирования
local isProcessing = false

-- 🧠 Проверка: жив ли персонаж
local function isAlive(character)
    return character and character.Parent and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

-- 🔗 Получить ссылки (с проверкой)
local function getLatestRefs()
    local character = player.Character
    if not character or not isAlive(character) then return nil, nil, nil end
    local backpack = player:FindFirstChild("Backpack")
    local stand = player:FindFirstChild("Stand")
    return character, backpack, stand
end

-- 🔍 Найти инструмент
local function findTool(name)
    local character, backpack = getLatestRefs()
    if not character or not backpack then return nil end
    return character:FindFirstChild(name) or backpack:FindFirstChild(name)
end

-- 🧷 Надеть инструмент
local function equipTool(tool)
    if not tool or tool.Parent == player.Character then return end
    pcall(function() tool.Parent = player.Character end)
    task.wait(0.1) -- минимальная задержка
end

-- 🛒 Получить предмет с умным ожиданием
local function ensureItem(itemName)
    if findTool(itemName) then return true end

    local character = player.Character
    if not isAlive(character) then
        print("[Предмет] ⚠️ Персонаж мёртв — не покупаем:", itemName)
        return false
    end

    print("[Предмет] 🚀 Запрашиваем:", itemName)
    pcall(function() giveitem:FireServer(itemName) end)

    -- ⏱️ Разное ожидание: Rokakaka — дольше
    local maxWait = (itemName == "RokakakaFruit") and 4 or 1.5
    local start = tick()

    repeat
        task.wait(0.2)
        if findTool(itemName) then
            print("[Предмет] ✅ Получен:", itemName)
            return true
        end
    until tick() - start > maxWait

    warn("[Предмет] ❌ Не получил:", itemName)
    return false
end

-- 🌐 Отправка вебхука
local function sendWebhook(standName)
    if not getgenv().enable_webhook then return end
    if not getgenv().webhook_url_autostand or not string.find(getgenv().webhook_url_autostand, "webhooks") then return end

    local lower = string.lower(standName)
    local shouldSend = false
    for _, name in ipairs(getgenv().if_send_webhook) do
        if string.find(lower, string.lower(name)) then
            shouldSend = true
            break
        end
    end
    if not shouldSend then return end

    local httpRequest = http_request or (syn and syn.request) or request
    if not httpRequest then return end

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

    local success, response = pcall(function()
        return httpRequest({
            Url = getgenv().webhook_url_autostand,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)

    if success and response and (response.StatusCode == 200 or response.StatusCode == 204) then
        print("✅ [Вебхук] Отправлен:", standName)
    end
end

-- 🔁 Сброс стэнда (мгновенно, но безопасно)
local function tryResetStand()
    if isProcessing then return end
    local character, _, stand = getLatestRefs()
    if not character or not stand or not isAlive(character) then return end

    if isProtectedStand(stand.Value) then
        print("🔒 [Сброс] ❌ Защищённый стенд — не сбрасываем:", stand.Value)
        return
    end

    if stand.Value == "None" then return end

    isProcessing = true

    local rokakaka = findTool("RokakakaFruit")
    if not rokakaka then
        if not ensureItem("RokakakaFruit") then
            isProcessing = false
            return
        end
        rokakaka = findTool("RokakakaFruit")
        if not rokakaka then
            isProcessing = false
            return
        end
    end

    equipTool(rokakaka)
    if rokakaka.Parent ~= character then
        isProcessing = false
        return
    end

    print("🔁 [Сброс] Мгновенный сброс стэнда...")
    pcall(function()
        fruitevent:InvokeServer(rokakaka, character, 2)
    end)

    isProcessing = false
end

-- 🎯 Получение стэнда (быстро)
local function tryObtainStand()
    if isProcessing then return end
    local character, _, stand = getLatestRefs()
    if not character or not stand or not isAlive(character) then return end

    if isProtectedStand(stand.Value) then return end
    if stand.Value ~= "None" then return end

    isProcessing = true

    local luckyArrow = findTool("LuckyStandArrow")
    if not luckyArrow then
        if not ensureItem("LuckyStandArrow") then
            isProcessing = false
            return
        end
        luckyArrow = findTool("LuckyStandArrow")
        if not luckyArrow then
            isProcessing = false
            return
        end
    end

    equipTool(luckyArrow)
    if luckyArrow.Parent ~= character then
        isProcessing = false
        return
    end

    print("🎯 [Получение] Используем стрелу...")
    pcall(function()
        luckyarrowevent:InvokeServer(luckyArrow, character, 0)
    end)

    -- ✅ Проверка результата через 0.6 сек — минимально
    task.delay(0.6, function()
        if not isAlive(character) then return end
        local _, _, newStand = getLatestRefs()
        if not newStand or newStand.Value == "None" or newStand.Value == stand.Value then return end
        if isProtectedStand(newStand.Value) then
            print("🎉 [УСПЕХ] Получен ЗАЩИЩЁННЫЙ стенд:", newStand.Value)
            sendWebhook(newStand.Value)
        else
            print("🔄 [Авто] Получен обычный стенд:", newStand.Value, "— сбрасываем...")
            tryResetStand()
        end
    end)

    isProcessing = false
end

-- 🔄 Обработчик изменения Stand.Value (мгновенная реакция)
player.Stand.Changed:Connect(function()
    task.spawn(function()
        task.wait(0.1) -- минимальная стабильность
        local _, _, stand = getLatestRefs()
        if not stand then return end

        if stand.Value ~= "None" and not isProtectedStand(stand.Value) then
            print("⚡ [Авто] Обычный стенд — сбрасываем...")
            tryResetStand()
        end

        if stand.Value == "None" then
            task.wait(0.2)
            tryObtainStand()
        end
    end)
end)

-- 🆕 После респауна
player.CharacterAdded:Connect(function(character)
    isProcessing = false
    print("🆕 [Респ] Персонаж перезагружен.")
    task.wait(0.3)
    if isAlive(character) then
        -- Ничего не запускаем — пусть сработает Stand.Changed
    end
end)

-- ✅ Запуск при старте
task.spawn(function()
    print("🚀 [Скрипт] Auto Stand — запущен.")
    local _, _, stand = getLatestRefs()
    if stand and stand.Value == "None" then
        task.wait(0.5)
        tryObtainStand()
    end
end)
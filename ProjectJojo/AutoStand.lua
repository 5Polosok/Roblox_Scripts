-- 🔧 НАСТРОЙКИ
getgenv().protected_stands = getgenv().protected_stands or {
    "gold", "wonder", "tusk", "d4", "emperor"
}

getgenv().if_send_webhook = {
    "gold", "wonder", "tusk", "d4c", "cream", "starplatinum",
    "theworld", "whitesnake", "kingcrimson", "killerqueen", "mandom",
}

getgenv().webhook_url_autostand = getgenv().webhook_url_autostand or "ВАШ_ВЕБХУК_ЗДЕСЬ"
getgenv().enable_webhook = getgenv().enable_webhook ~= false
getgenv().autoResetAfterObtain = true
getgenv().autoBuyItems = true
getgenv().buyInterval = 0.3

-- 🔍 Проверка: защищён ли стенд
local function isProtectedStand(standName)
    if not standName or standName == "None" then return false end
    local lower = string.lower(standName)
    for _, protected in ipairs(getgenv().protected_stands) do
        if string.find(lower, protected) then
            return true
        end
    end
    return false
end

-- 🧩 Сервисы
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- 🔌 Remotes
local fruitevent = ReplicatedStorage.Logic:WaitForChild("fruitevent")
local luckyarrowevent = ReplicatedStorage.Logic:WaitForChild("luckyarrowevent")
local giveitem = ReplicatedStorage.Logic:WaitForChild("giveitem")

-- 🧍 Проверка жизни
local function isAlive(character)
    return character and character.Parent ~= nil 
        and character:FindFirstChild("Humanoid") 
        and character.Humanoid.Health > 0
end

-- 🔗 Получить ссылки
local function getLatestRefs()
    local character = player.Character
    if not character or not isAlive(character) then
        return nil, nil, nil
    end
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
    if not tool then return end
    local character = player.Character
    if tool.Parent ~= character and character and isAlive(character) then
        pcall(function() tool.Parent = character end)
    end
end

-- 🌐 Отправка вебхука
local function sendWebhook(standName)
    if not getgenv().enable_webhook or not getgenv().autoResetAfterObtain then return end
    if not getgenv().webhook_url_autostand or not string.find(getgenv().webhook_url_autostand, "webhooks") then
        return
    end

    local lowerStand = string.lower(standName)
    local shouldSend = false
    for _, name in ipairs(getgenv().if_send_webhook) do
        if string.find(lowerStand, string.lower(name)) then
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
        footer = { text = "Fast Auto-Reset System" },
        author = {
            name = "Игрок: " .. player.Name,
            icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
        }
    }

    local data = { embeds = { embed } }
    local body = HttpService:JSONEncode(data)

    pcall(function()
        httpRequest({
            Url = getgenv().webhook_url_autostand,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)
end

-- 🔁 Флаги
local isUsingArrow = false
local hasProcessedNewStand = false
local lastLoggedStand = nil  -- Чтобы не дублировать

-- 📝 Логгирование полученного стенда
local function logObtainedStand(standName)
    if not standName or standName == "None" or standName == "Human" then return end
    if lastLoggedStand == standName then return end  -- Защита от дублей

    lastLoggedStand = standName
    local status = isProtectedStand(standName) and "🛡️ ЗАЩИЩЁННЫЙ" or "🎉 НОВЫЙ"
    print(("[ЛОГ] %s: %s"):format(status, standName))

    -- Отправка вебхука
    sendWebhook(standName)
end

-- 🏹 Использовать Lucky Arrow
local function useLuckyArrow()
    if isUsingArrow then return end
    isUsingArrow = true

    local character, _, stand = getLatestRefs()
    if not character or not stand or not isAlive(character) then
        isUsingArrow = false
        return
    end

    if stand.Value ~= "None" then
        isUsingArrow = false
        return
    end

    local arrow = findTool("LuckyStandArrow")
    if not arrow then
        isUsingArrow = false
        return
    end

    equipTool(arrow)
    if arrow.Parent ~= character then
        isUsingArrow = false
        return
    end

    print("[Стрела] 🏹 Используем Lucky Stand Arrow...")
    pcall(function()
        luckyarrowevent:InvokeServer(arrow, character, 0)
    end)

    -- 🔥 СРАЗУ после стрелы — пробуем сбросить (в окне до ресета!)
    task.spawn(function()
        task.wait(0.1)
        local rokakaka = findTool("RokakakaFruit")
        if not rokakaka then return end

        local _, _, stand = getLatestRefs()
        if not stand or isProtectedStand(stand.Value) then
            return  -- ❌ Не сбрасываем, если стенд защищён!
        end

        equipTool(rokakaka)
        local char = player.Character
        if rokakaka.Parent == char and char and isAlive(char) then
            print("⚡ [FAST RESET] Сбрасываем стенд: " .. (stand.Value or "Unknown"))
            pcall(function()
                fruitevent:InvokeServer(rokakaka, char, 2)
            end)
        end
    end)

    isUsingArrow = false
end

-- 🔁 Сбросить текущий стенд (если есть и не защищён)
local function tryResetCurrentStand()
    local character, _, stand = getLatestRefs()
    if not character or not stand or not isAlive(character) then return end

    if isProtectedStand(stand.Value) then
        print("[Сброс] ⛔ Защищённый стенд: " .. stand.Value)
        return
    end

    if stand.Value == "None" then return end

    local rokakaka = findTool("RokakakaFruit")
    if not rokakaka then return end

    equipTool(rokakaka)
    if rokakaka.Parent ~= character then return end

    print("⚡ [Сброс] Сбрасываем текущий стенд: " .. stand.Value)
    pcall(function()
        fruitevent:InvokeServer(rokakaka, character, 2)
    end)
end

-- 🔁 ЦИКЛ: Автопокупка (с проверкой Backpack)
task.spawn(function()
    while true do
        task.wait(getgenv().buyInterval)
        if not getgenv().autoBuyItems then continue end

        local character = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if not character or not backpack or not isAlive(character) then
            continue  -- 🔴 Ждём, пока будет Character и Backpack
        end

        for _, item in ipairs({ "RokakakaFruit", "LuckyStandArrow" }) do
            if not findTool(item) then  -- findTool проверяет Character и Backpack
                pcall(function()
                    giveitem:FireServer(item)
                end)
                task.wait(0.05)  -- ❗ Небольшая задержка между покупками, чтобы не сломать очередь
            end
        end
    end
end)

-- 🆕 При появлении персонажа
player.CharacterAdded:Connect(function()
    task.wait(0.3)
    isUsingArrow = false
    hasProcessedNewStand = false
    lastLoggedStand = nil  -- Сброс лога при респе

    -- Если уже есть стенд — сбросим
    local _, _, stand = getLatestRefs()
    if stand and stand.Value ~= "None" and not isProtectedStand(stand.Value) then
        print("[Респ] 🔄 Есть стенд: " .. stand.Value .. " — сбрасываем...")
        tryResetCurrentStand()
    end
end)

-- 🔔 Отслеживание изменения Stand.Value
player.Stand.Changed:Connect(function(newStand)
    task.spawn(function()
        task.wait(0.1) -- Дать время на синхронизацию
        local _, _, stand = getLatestRefs()
        if not stand then return end

        -- Только если это реальный стенд и не "None"
        if stand.Value ~= "None" and stand.Value ~= "Human" and stand.Value ~= lastLoggedStand then
            logObtainedStand(stand.Value)
        end
    end)
end)

-- 🚀 Запуск при старте
task.spawn(function()
    task.wait(1)
    local stand = player:FindFirstChild("Stand")
    if stand and stand.Value ~= "None" and not isProtectedStand(stand.Value) then
        print("[Старт] 🔄 Уже есть стенд: " .. stand.Value .. " — сбрасываем...")
        tryResetCurrentStand()
    end

    -- Основной цикл
    while true do
        task.wait(1)
        if getgenv().autoResetAfterObtain and player.Stand.Value == "None" then
            useLuckyArrow()
        end
    end
end)

print("[Скрипт] ✅ Мгновенный сброс + ЛОГГИРОВАНИЕ стендов активен.")
print("🔧 Управление: getgenv().autoBuyItems = true/false | autoResetAfterObtain = true/false")
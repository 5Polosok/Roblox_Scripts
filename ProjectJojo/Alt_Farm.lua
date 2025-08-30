-- === Настройки ===
getgenv().skibidi = true
getgenv().targetPlayerName = "SPolosok"        -- Имя игрока, которому передавать
getgenv().autoGiveAllEnabled = true          -- Включить авто-передачу
getgenv().giveCooldown = 2.0                   -- Задержка между передачами
getgenv().itemsToSkip = { "StandArrow", "RokakakaFruit" } -- Исключения

-- === Сервисы ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local ChatService = game:GetService("TextChatService")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === Отправка сообщения в чат ===
local function sendChatMessage(message)
    pcall(function()
        if ChatService then
            ChatService:Chat(PlayerGui, message, Enum.ChatColor.White)
        else
            local sayMsg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                            and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
            if sayMsg then
                sayMsg:FireServer(message, "All")
            end
        end
    end)
end

-- === Получить все инструменты из инвентаря ===
local function getAllTools()
    local tools = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and not table.find(getgenv().itemsToSkip, tool.Name) then
                table.insert(tools, tool)
            end
        end
    end
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and not table.find(getgenv().itemsToSkip, tool.Name) then
                table.insert(tools, tool)
            end
        end
    end
    return tools
end

-- === Экипировать инструмент ===
local function equipTool(tool)
    if not tool or not tool:IsA("Tool") or not LocalPlayer.Character then return false end
    pcall(function()
        tool.Parent = LocalPlayer.Character
    end)
    return true
end

-- === Функция: передача всех предметов с ожиданием игрока ===
local function giveAllItemsToPlayer(playerName)
    print(`Ожидание игрока: {playerName}...`)

    -- Проверяем, есть ли игрок уже
    local target = Players:FindFirstChild(playerName)
    if not target then
        -- Ждём появления игрока
        local playerAddedConn = nil
        local timeout = false

        playerAddedConn = Players.PlayerAdded:Connect(function(p)
            if p.Name == playerName then
                target = p
                playerAddedConn:Disconnect()
            end
        end)

        -- Таймаут на 30 секунд
        task.delay(30, function()
            if not target and not timeout then
                timeout = true
                warn(`Игрок {playerName} не вошёл за 30 сек.`)
            end
        end)

        repeat task.wait(0.5) until target or timeout or not getgenv().autoGiveAllEnabled
        if playerAddedConn then playerAddedConn:Disconnect() end
    end

    if not target or timeout then
        warn(`Не удалось найти игрока: {playerName}`)
        return
    end

    print(`Игрок {playerName} найден! Начинаем передачу...`)
    local tools = getAllTools()

    if #tools == 0 then
        print("Нет предметов для передачи.")
        return
    end

    for i, tool in ipairs(tools) do
        if not getgenv().skibidi or not getgenv().autoGiveAllEnabled then
            print("Передача остановлена.")
            break
        end

        if equipTool(tool) then
            sendChatMessage(`!giveitem {playerName}`)
            print(`Передано: {tool.Name} ({i}/{#tools})`)
        else
            warn(`Не удалось передать: {tool.Name}`)
        end

        task.wait(getgenv().giveCooldown)
    end

    print("✅ Все предметы переданы!")
end

-- === Основной поток ===
local giveThread = nil

local function startAutoGive()
    if giveThread then task.cancel(giveThread) end

    giveThread = task.spawn(function()
        while getgenv().autoGiveAllEnabled and getgenv().skibidi do
            pcall(function()
                giveAllItemsToPlayer(getgenv().targetPlayerName)
            end)
            task.wait(1) -- Пауза перед следующей попыткой (если нужно повторять)
        end
    end)
end

-- === Управление потоком ===
task.spawn(function()
    while getgenv().skibidi do
        if getgenv().autoGiveAllEnabled and (not giveThread or not task.isrunning(giveThread)) then
            startAutoGive()
        elseif not getgenv().autoGiveAllEnabled and giveThread then
            task.cancel(giveThread)
            giveThread = nil
        end
        task.wait(1)
    end
end)

print("✅ Скрипт загружен. Включи: getgenv().autoGiveAllEnabled = true")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

-- ===== НАСТРОЙКИ =====
local TARGET_PLAYER_NAME = getgenv().nickname_to_give  -- 👉 Замени ник
local GIVE_COMMAND = "!giveitem " .. TARGET_PLAYER_NAME
local DELAY_BETWEEN_ITEMS = 0.8  -- Минимальная задержка между предметами
local CHECK_INTERVAL = 3        -- Как часто проверять игрока
-- =====================
-- Отправка через TextChatService (с попыткой разных каналов)
local function sendChatMessage(message)
    local channels = {"RBXGeneral", "Team", "All"}
    for _, name in ipairs(channels) do
        local channel = TextChatService.TextChannels:FindFirstChild(name)
        if channel then
            pcall(function()
                channel:SendAsync(message)
                print("✅ Отправлено: " .. message)
            end)
            return
        end
    end
    warn("❌ Не найден активный канал чата")
end

-- Передача всех инструментов без ожидания
local function giveAllTools()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then
        print("❌ Рюкзак не найден")
        return
    end

    local tools = {}
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(tools, item)
        end
    end
    --Отправка на случай если изначально в руке предмет
    task.wait(5)
    sendChatMessage(GIVE_COMMAND)
    if #tools == 0 then
        print("📭 Нет инструментов для передачи")
        return
    end

    print(`📤 Передача {#tools} инструментов игроку {TARGET_PLAYER_NAME}`)

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    character:WaitForChild("Humanoid", 5)
    for i, tool in ipairs(tools) do
        print(`🔧 Экипируем: {tool.Name} ({i}/{#tools})`)

        -- Просто пытаемся экипировать
        pcall(function()
            tool.Parent = character
        end)

        -- Отправляем команду СРАЗУ
        sendChatMessage(GIVE_COMMAND)

        task.wait(DELAY_BETWEEN_ITEMS)
    end

    print("🎉 Все инструменты переданы!")
end

-- Ждём нужного игрока
print(`🔍 Ожидание игрока: {TARGET_PLAYER_NAME}`)

while true do
    local targetPlayer = Players:FindFirstChild(TARGET_PLAYER_NAME)
    if targetPlayer then
        print(`✅ Игрок {TARGET_PLAYER_NAME} найден!`)
        giveAllTools()
        break  -- Убери, если хочешь повторять при каждом заходе
    else
        print(`❌ {TARGET_PLAYER_NAME} не в игре. Проверка через {CHECK_INTERVAL} сек...`)
    end
    task.wait(CHECK_INTERVAL)
end
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

-- ===== НАСТРОЙКИ =====
local TARGET_PLAYER_NAME = getgenv().nickname_to_give
local GIVE_COMMAND = "!giveitem " .. TARGET_PLAYER_NAME
local DELAY_BETWEEN_ITEMS = 0.8
local CHECK_INTERVAL = 3
-- =====================

-- Отправка сообщения
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

-- Передача всех инструментов
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

    -- Отправка на случай, если предмет уже в руке
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
        pcall(function()
            tool.Parent = character
        end)
        sendChatMessage(GIVE_COMMAND)
        task.wait(DELAY_BETWEEN_ITEMS)
    end

    print("🎉 Все инструменты переданы!")
end

-- === Основной цикл: работает постоянно ===
print(`🔍 Ожидание захода игрока: {TARGET_PLAYER_NAME}`)

local wasPresent = false  -- Флаг: был ли игрок в прошлой проверке

while true do
    local targetPlayer = Players:FindFirstChild(TARGET_PLAYER_NAME)
    local isPresent = targetPlayer ~= nil

    -- Если игрок только что зашёл (был не здесь → стал здесь)
    if isPresent and not wasPresent then
        print(`✅ Игрок {TARGET_PLAYER_NAME} зашёл! Передаём предметы...`)
        giveAllTools()
    end

    -- Обновляем состояние
    wasPresent = isPresent

    -- Проверяем каждые CHECK_INTERVAL секунд
    task.wait(CHECK_INTERVAL)
end
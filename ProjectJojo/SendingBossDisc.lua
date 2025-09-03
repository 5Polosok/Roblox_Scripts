-- 🔧 НАСТРОЙКИ
getgenv().webhook_url_bossdisc = getgenv().webhook_url_bossdisc or "ВАШ_ВЕБХУК_ЗДЕСЬ"
getgenv().enable_bossdisc_webhook = getgenv().enable_bossdisc_webhook ~= false

-- 🧩 Сервисы
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 🔗 Функция отправки вебхука
local function sendBossDiscWebhook(standValue)
    if not getgenv().enable_bossdisc_webhook then return end
    if not getgenv().webhook_url_bossdisc or not string.find(getgenv().webhook_url_bossdisc, "webhooks") then
        return
    end

    local httpRequest = http_request or (syn and syn.request) or request
    if not httpRequest then return end

    local embed = {
        title = "🔥 Project JOJO",
        description = "**" .. player.Name .. "** обнаружил `bossdisc` на карте!",
        fields = {{
            name = "🎯 Найденный Стенд",
            value = "```" .. tostring(standValue) .. "```",
            inline = false
        }},
        color = 5814783,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        footer = { text = "BossDisc Monitor System" },
        author = {
            name = "Игрок: " .. player.Name,
            icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
        }
    }

    local data = { embeds = { embed } }
    local body = HttpService:JSONEncode(data)

    pcall(function()
        httpRequest({
            Url = getgenv().webhook_url_bossdisc,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)
end

-- 🔍 Проверка: есть ли bossdisc?
local function checkBossDisc(disc)
    if not disc or not disc:IsDescendantOf(Workspace) then return end

    local stand = disc:FindFirstChild("stand")
    if not stand then
        task.wait(2)
        stand = disc:FindFirstChild("stand")
    end

    if not stand then
        print("❌ stand не найден")
        return
    end

    -- ✅ Теперь мы проверяем, является ли stand сам по себе ValueBase
    if stand then
        local value = stand.Value
        if value and value ~= "" then
            print("✅ Найденный стенд :", value)
            sendBossDiscWebhook(value)
        end
    end
end

-- 🔎 Проверка при старте
print("🔄 Запуск мониторинга bossdisc...")
local existing = Workspace:FindFirstChild("bossdisc", true)
if existing then
    print("🟢 Найден существующий bossdisc:", existing:GetFullName())
    checkBossDisc(existing)
else
    print("🟡 bossdisc не найден при старте.")
end

-- 🕵️ Отслеживание новых
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "bossdisc" then
        print("🆕 Появился bossdisc:", child:GetFullName())
        task.wait(0.5)
        checkBossDisc(child)
    end
end)

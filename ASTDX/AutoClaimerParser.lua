-- ASTD X Auto Redeem 17687504411
-- Game: https://www.roblox.com/games//

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


if game.PlaceId ~= 17687504411 then
    warn("Запускайте только в ASTD X (PlaceID: 17687504411)")
    return
end

-- Конфиг
local DELAY = 0.2
local MAX_RETRIES = 2
local REDEEM_LEVELS = true

-- Кэш кодов
local redeemed = {}
local failed = {}

-- Улучшенный парсер вики
local function getWikiCodes()
    local success, html = pcall(function()
        return game:HttpGet("https://astdx.fandom.com/wiki/Codes?action=raw")
    end)
    
    if not success then
        warn("Ошибка загрузки вики: " .. html)
        return {}
    end

    local codes = {}
    
    -- Парсим по цвету Tomato
    for code in html:gmatch('color:Tomato[^>]->([A-Z0-9]+)<') do
        table.insert(codes, code)
    end
    
    -- Альтернативные методы парсинга
    if #codes == 0 then
        for line in html:gmatch('Code:.-<b>([A-Z0-9]+)</b>') do
            table.insert(codes, line)
        end
    end
    
    return codes
end

-- Функция ввода кода
local function redeem(code)
    if table.find(redeemed, code) then return end
    for attempt = 1, MAX_RETRIES do
        local args = {
            {Type = "Code", Mode = "Redeem", Code = code}
        }
        
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.GetFunction:InvokeServer(unpack(args))
        end)
        
        if success then
            table.insert(redeemed, code)
            print("✅ Успех: " .. code)
            return true
        else
            warn(string.format("⚠️ Попытка %d/%d: %s | Ошибка: %s", 
                attempt, MAX_RETRIES, code, result))
        end
        
        task.wait(DELAY)
    end
    
    table.insert(failed, code)
    return false
end

-- Ввод level-кодов
local function redeemLevels()
    if not REDEEM_LEVELS then return end
    
    for lvl = 100, 0, -5 do
        local args = {
            {Type = "Code", Mode = "Level", Code = lvl}
        }
        
        pcall(function()
            ReplicatedStorage.Remotes.GetFunction:InvokeServer(unpack(args))
            print("⚡ Level код: " .. lvl)
        end)
        
        task.wait(DELAY)
    end
end

-- Основная функция
local function main()
    print("🔄 Получаю коды с вики...")
    local codes = getWikiCodes()
    
    if #codes > 0 then
        print("🎯 Найдено кодов: " .. #codes)
        redeemLevels() -- Сначала level-коды
        
        print("🔥 Начинаю ввод промо-кодов...")
        for _, code in ipairs(codes) do
            redeem(code)
            task.wait(DELAY)
        end
        
        if #failed > 0 then
            warn("❌ Не удалось ввести: " .. table.concat(failed, ", "))
        end
        
        print("✨ Готово! Введено: " .. #redeemed .. " кодов")
    else
        warn("🚫 Коды не найдены!")
    end
end

-- Автозапуск
task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    task.wait(3)
    
    if Players.LocalPlayer then
        main()
    else
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        task.wait(1)
        main()
    end
end)
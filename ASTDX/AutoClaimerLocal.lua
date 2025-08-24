if game.PlaceId == 17687504411 then
    -- Настройки
    local cooldown = 0.01 -- Задержка между запросами
    local startLevel = 100 -- Начальный уровень для кодов уровня
    
    -- Сервисы
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local GetFunction = Remotes:WaitForChild("GetFunction")
    
    -- Список кодов для активации
    local codes = {
        "ALOTOFSHUT", "THANKYOUFOR540KLIKES", "SRRYFORSHUTDOWN", "THANKYOUFORPATIENCE", "MOREUPDATES", "MINORDELAY", "UPDATE4", "BIGFIX",
        "SORRY4DELAYZ", "NEWMODENEXTUPDATE", "THANKYOUFOR500KLIKES", "UPDNEXTWEEKEND",
        "THANKYOUFOR500MVISITS", "2MGROUPMEMBERS", "MBSHUTDOWNB", "THANKYOUFORLIKES123",
        "NEXTLIKEGOAL500K", "UPD2", "FOLLOWS10KBREAD", "THREEHUNDREDTHOUSANDPLAYERS",
        "LIKEF5", "AFIRSTTIME3001", "FREENIMBUSMOUNT"
    }
    
    -- Функция для безопасного выполнения запросов
    local function safeInvoke(args)
        local success, result = pcall(function()
            return GetFunction:InvokeServer(unpack(args))
        end)
        
        if not success then
            warn("Ошибка при выполнении запроса:", result)
            return false
        end
        return true
    end
    
    -- Активация кодов
    print("Начинаем активацию кодов...")
    for _, code in ipairs(codes) do
        local args = {{
            Type = "Code",
            Mode = "Redeem",
            Code = code
        }}
        
        if safeInvoke(args) then
            print("Успешно активирован код:", code)
        else
            print("Не удалось активировать код:", code)
        end
        task.wait(cooldown)
    end
    
    -- Активация кодов уровня
    print("\nНачинаем активацию кодов уровня...")
    local currentLevel = startLevel
    while currentLevel >= 0 do
        local args = {{
            Type = "Code",
            Mode = "Level",
            Code = currentLevel
        }}
        
        if safeInvoke(args) then
            print("Успешно активирован код уровня:", currentLevel)
        else
            print("Не удалось активировать код уровня:", currentLevel)
        end
        
        currentLevel = currentLevel - 5
        task.wait(cooldown)
    end
    
    print("\nВсе коды были обработаны!")
else
    warn("Этот скрипт предназначен для другого места (PlaceId: 17687504411)")
end
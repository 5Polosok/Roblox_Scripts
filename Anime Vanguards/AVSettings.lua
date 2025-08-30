    if game.PlaceId ~= 16146832113 then return end

    -- 🛠️ Список категорий и настроек для включения
    local SETTINGS_TO_ENABLE = {
        ["Gameplay"] = {
            "AutoSkipWaves",
            "DisableMatchEndRewardsView",
        },
        ["Graphics"] = {
            "LowDetailMode",
            "DisableViewCutscenes",
            "DisableCameraShake",
            "DisableDepthOfField"
        },
        ["Miscellaneous"] = {
            "SkipSummonAnimation"
        },
        ["Events"] = {
            "RandomSacrificeDomain"
        },
        ["Enemies"] = {
            "DisableEnemyTags",
            "SimplifiedEnemyGui"
        },
        ["Units"] = {
            "DisableDamageIndicators",
            "DisableVisualEffects",
        }
    }
    -- 🔧 Функция: включить настройку
    local function toggleSetting(categoryName, settingName)
        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
        local sliderPath = playerGui:FindFirstChild("Windows")
            and playerGui.Windows.Settings.Holder.Main.ScrollingFrame:FindFirstChild(categoryName)
            and playerGui.Windows.Settings.Holder.Main.ScrollingFrame[categoryName]:FindFirstChild(settingName)
            and playerGui.Windows.Settings.Holder.Main.ScrollingFrame[categoryName][settingName]:FindFirstChild("Slider")

        if not sliderPath then
            warn(`❌ Настройка {settingName} не найдена в {categoryName}`)
            return
        end

        local ball = sliderPath:FindFirstChild("Ball")
        local uiStroke = ball and ball:FindFirstChild("UIStroke")

        -- Если настройка выключена (красный) → включаем
        if uiStroke and uiStroke.Color == Color3.fromRGB(0, 255, 180) and settingName == "RandomSacrificeDomain" then
            local args = { "Toggle", settingName }
            pcall(function()
                game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Settings"):WaitForChild("SettingsEvent"):FireServer(unpack(args))
            end)
            print(`❌ {settingName} выключен`)
            return
        elseif settingName == "RandomSacrificeDomain" then
            print("❌ {settingName} уже выключен")
        end
        if uiStroke and uiStroke.Color == Color3.fromRGB(255, 0, 75) and settingName ~= "RandomSacrificeDomain" then
            local args = { "Toggle", settingName }
            pcall(function()
                game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Settings"):WaitForChild("SettingsEvent"):FireServer(unpack(args))
            end)
            print(`✅ {settingName} включён`)
        else
            print(`🟢 {settingName} уже включён`)
        end
    end

    -- 🚀 Запуск
    task.spawn(function()
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        task.wait(2) -- Ждём загрузки GUI

        print("🔧 Автовключение настроек...")

        -- Перебираем все категории и настройки
        for categoryName, settingsList in pairs(SETTINGS_TO_ENABLE) do
            for _, settingName in ipairs(settingsList) do
                pcall(toggleSetting, categoryName, settingName)
                task.wait(0.1) -- Небольшая пауза между настройками
            end
        end

        print("✅ Все настройки обработаны")
    end)
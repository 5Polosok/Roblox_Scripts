-- 🔒 Безопасная инициализация
if not getgenv then
    return warn("Скрипт работает только в среде с getgenv (Synapse X, Krnl)")
end
if not getgenv().FarmAltsFunpay then return end

-- ⚙️ Глобальные настройки
getgenv().days_amount = 3
getgenv().AutoUpgradeEnabled = true
getgenv().MatchRestartEnabled = true

-- 🌐 Отключить аудио (для FPS и тишины)
game:GetService("SoundService").SoundsDisabled = true

-- 📍 Новые позиции для расстановки юнитов
local TARGET_POSITIONS = {
    Vector3.new(424.83978271484375, 3.7291393280029297, -350.6957702636719),
    Vector3.new(424.9408874511719, 3.7291393280029297, -353.44927978515625),
    Vector3.new(430.9632873535156, 3.7291393280029297, -351.3844299316406),
    Vector3.new(430.8381042480469, 3.7291393280029297, -354.10968017578125),
    Vector3.new(425.84222412109375, 3.7291393280029297, -347.7817687988281),
    Vector3.new(428.85882568359375, 3.7291393280029297, -346.37255859375)
}

-- ⏳ Универсальная случайная задержка
local function randomDelay(min, max)
    local delay = math.random(min * 100, max * 100) / 100
    task.wait(delay)
    return delay
end

-- 🧠 ОСНОВНАЯ ЛОГИКА
local function main()
    local placeId = game.PlaceId
    local player = game:GetService("Players").LocalPlayer

    -- ✅ Анти-афк
    local function enableAntiIdle()
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
    enableAntiIdle()

    if placeId == 16146832113 then
        -- 🌞 Меню: дейлики, батлпасс, запуск
        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player.PlayerGui:FindFirstChild("Windows")

        pcall(function()
            local networking = game.ReplicatedStorage:WaitForChild("Networking", 10)
            networking:WaitForChild("Units"):WaitForChild("UnitSelectionEvent"):FireServer("Select", "Luffo")
            print("✅ Юнит Luffo выбран")
            randomDelay(0.3, 0.7)
        end)

        pcall(function()
            local unitsFrame = player.PlayerGui.Windows.Units.Holder.Main.Units
            for _, frame in pairs(unitsFrame:GetChildren()) do
                if frame:IsA("Frame") and frame.Name ~= "BuyMoreSpace" then
                    game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("EquipEvent"):FireServer("Equip", frame.Name)
                    print(`✅ Экипирован: {frame.Name}`)
                    break
                end
            end
        end)

        -- Дейлики, батлпасс, квесты, запуск матча
        pcall(function()
            local rewardEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("DailyRewardEvent")
            for _, season in pairs({"Summer", "Spring", "Special"}) do
                for day = 1, getgenv().days_amount do
                    rewardEvent:FireServer("Claim", {season, day})
                end
            end
        end)

        pcall(function()
            game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("BattlepassEvent"):FireServer("ClaimAll")
        end)

        pcall(function()
            game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Quests"):WaitForChild("ClaimQuest"):FireServer("ClaimAll")
        end)

        pcall(function()
            local lobbyEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("LobbyEvent")
            lobbyEvent:FireServer("AddMatch", {
                Difficulty = "Normal",
                Act = "Act1",
                StageType = "Story",
                Stage = "Stage1",
                FriendsOnly = true
            })
            lobbyEvent:FireServer("StartMatch")
        end)

    elseif placeId == 16277809958 then
        -- 🔥 Боёвка
        if not game:IsLoaded() then game.Loaded:Wait() end
        repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        -- 🧹 Очистка Map
        pcall(function()
            local map = game.Workspace:FindFirstChild("Map")
            if map then
                for _, v in pairs(map:GetChildren()) do
                    if v.Name ~= "Assets" and v.Name ~= "Terrain" then
                        pcall(v.Destroy, v)
                    end
                end
            end
        end)

        -- ⏭️ SkipWave
        local function fireSkipWaveEvent()
            pcall(function()
                local skipEvent = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("SkipWaveEvent", 5)
                if skipEvent then skipEvent:FireServer("Skip") end
            end)
        end

        -- 🧩 Вспомогательные функции
        local function isGameActive()
            local hotbar = player.PlayerGui:FindFirstChild("Hotbar")
            local endScreen = player.PlayerGui:FindFirstChild("EndScreen")
            return hotbar and hotbar.Enabled and not (endScreen and endScreen.Enabled)
        end

        local function isWaveActive()
            local wave = game.Workspace:FindFirstChild("WaveController")
            return wave and wave:FindFirstChild("CurrentWave") and wave.CurrentWave.Value > 0
        end

        local function waitForWaveStart()
            while getgenv().MatchRestartEnabled do
                if isGameActive() and isWaveActive() then break end
                task.wait(1)
            end
        end

        local function getPlayerMoney()
            local yen = player.PlayerGui:FindFirstChild("Hotbar")
            if not yen then return 0 end
            local text = yen.Main.Yen.Text
            return tonumber(string.gsub(text, "%D", "")) or 0
        end

        local function getUnitCount()
            local units = game.Workspace:FindFirstChild("Units")
            return units and #units:GetChildren() or 0
        end

        local function isUnitAtExactPosition(pos, tol)
            local units = game.Workspace:FindFirstChild("Units")
            if not units then return false end
            for _, unit in pairs(units:GetChildren()) do
                local hrp = unit:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - pos).Magnitude <= tol then
                    return true
                end
            end
            return false
        end

        local function moveToPosition(pos)
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if not (hrp and humanoid) then return end
            humanoid:MoveTo(pos + Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
            task.wait(0.5)
        end

        local function deployUnit(pos, index)
            if getPlayerMoney() < 300 then return false end
            if isUnitAtExactPosition(pos, 1.8) then return true end

            local offset = pos + Vector3.new(
                (math.random(3,10)/1000) * (math.random(0,1)*2-1),
                0,
                (math.random(3,10)/1000) * (math.random(0,1)*2-1)
            )

            pcall(function()
                game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent"):FireServer("Render", {"Luffo", 39, offset, 0})
                task.wait(0.6)
            end)

            if isUnitAtExactPosition(offset, 2.0) then
                moveToPosition(offset)
                return true
            end

            pcall(function()
                game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent"):FireServer("Render", {"Luffo", 39, pos, 0})
                task.wait(0.6)
            end)

            if isUnitAtExactPosition(pos, 2.0) then
                moveToPosition(pos)
                return true
            end

            return false
        end

        local function deployAllUnits()
            unitLevels = {}
            if getUnitCount() >= 6 then return end
            while getPlayerMoney() < 300 do task.wait(2) end
            for i, pos in ipairs(TARGET_POSITIONS) do
                deployUnit(pos, i)
                task.wait(0.8, 1.5)
            end
        end

        local unitLevels = {}

        local function upgradeCheapestUnit()
            if getUnitCount() < 6 then deployAllUnits(); return end
            local currentMoney = getPlayerMoney()
            for _, unit in pairs(game.Workspace.Units:GetChildren()) do
                local name = unit.Name
                local level = unitLevels[name] or 1
                local cost = ({250, 400, 650, 900})[level]
                if cost and currentMoney >= cost then
                    game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("UnitEvent"):FireServer("Upgrade", name)
                    unitLevels[name] = level + 1
                    local hrp = unit:FindFirstChild("HumanoidRootPart")
                    if hrp then moveToPosition(hrp.Position) end
                    break
                end
            end
        end

        -- 🌐 Webhook: с защитой и ожиданием
        local function sendMatchResult()
            task.wait(2) -- Даём время GUI загрузиться
            local endScreen = player.PlayerGui:FindFirstChild("EndScreen")
            if not endScreen or not endScreen.Enabled then return end

            local main = endScreen:FindFirstChild("Holder")?.Main
            if not main then return end

            local time = main.StageStatistics?.PlayTime?.Amount?.Text or "0:00"
            local rewards = {}
            for _, r in pairs(main.InventoryTemplate:GetChildren()) do
                if r:IsA("Frame") and r.Name ~= "BuyMoreSpace" then
                    local n = r:FindFirstChild("Name")?.Text
                    local a = tonumber(r:FindFirstChild("Amount")?.Text) or 0
                    if n then table.insert(rewards, {n, a}) end
                end
            end

            local level = player.PlayerGui.Hotbar.Main.Level.Level.Text
            local embed = {
                title = "Anime Vanguards",
                fields = {
                    { name = "Name", value = `[${level}] ${player.Name}`, inline = false },
                    { name = "Result", value = `Planet Namak (Act1 Normal) - Finished\n- Time: ${time}\n- Reward:`, inline = false }
                },
                color = 5814783
            }

            for _, r in pairs(rewards) do
                table.insert(embed.fields, { name = "", value = `+${r[2]} ${r[1]}`, inline = false })
            end

            local data = { embeds = { embed } }
            local body = game:GetService("HttpService"):JSONEncode(data)
            pcall(function()
                request({
                    Url = getgenv().AV_WEBHOOK_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body
                })
            end)
        end

        -- 🔁 Циклы
        coroutine.wrap(function()
            while getgenv().AutoUpgradeEnabled do
                if isGameActive() then upgradeCheapestUnit() end
                task.wait(1.0, 1.8)
            end
        end)()

        coroutine.wrap(function()
            while getgenv().MatchRestartEnabled do
                local endScreen = player.PlayerGui:FindFirstChild("EndScreen")
                if endScreen and endScreen.Enabled then
                    print("🔚 Матч завершён. Перезапускаем...")

                    -- 🔁 Голосуем за реплей (с ожиданием)
                    pcall(function()
                        local event = game.ReplicatedStorage:WaitForChild("Networking"):WaitForChild("EndScreen"):WaitForChild("VoteEvent", 5)
                        if event then event:FireServer("Retry") end
                    end)

                    task.wait(3)
                    fireSkipWaveEvent()
                    task.wait(8, 12)
                    waitForWaveStart()
                    deployAllUnits()

                    task.delay(1, sendMatchResult)
                end
                task.wait(2)
            end
        end)()

        -- 🚀 Старт
        fireSkipWaveEvent()
        waitForWaveStart()
        deployAllUnits()
    end
end

-- 🛡️ Запуск
pcall(function()
    randomDelay(0.5, 1.5)
    main()
end)

-- 🛑 Остановка
function stopScript()
    getgenv().AutoUpgradeEnabled = false
    getgenv().MatchRestartEnabled = false
    print("🛑 Скрипт остановлен")
end

print("🟢 Скрипт загружен. Используй stopScript().")

-- 📱 Мобильная кнопка + Очистка Entities
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(2)

    -- 🔘 Кнопка
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileCombatHelper"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 0, 40)
    button.Position = UDim2.new(0, 10, 1, -50)
    button.Text = "3D: ON"
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    button.BorderColor3 = Color3.fromRGB(200, 200, 200)
    button.BorderSizePixel = 2
    button.Parent = screenGui

    getgenv().RenderingEnabled = true
    game:GetService("RunService"):Set3dRenderingEnabled(true)

    button.MouseButton1Click:Connect(function()
        getgenv().RenderingEnabled = not getgenv().RenderingEnabled
        game:GetService("RunService"):Set3dRenderingEnabled(getgenv().RenderingEnabled)
        button.Text = `3D: ${getgenv().RenderingEnabled and "ON" or "OFF"}`
        button.BackgroundColor3 = getgenv().RenderingEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    end)

    -- 🧹 Очистка Entities
    local ws = game:GetService("Workspace")
    local function cleanup(child)
        if child.Name == "Entities" then
            child.ChildAdded:Connect(function(c)
                task.delay(0.05, function()
                    if c and not c:IsDescendantOf(ws.Map) then
                        pcall(c.Destroy, c)
                    end
                end)
            end)
            for _, c in pairs(child:GetChildren()) do
                if not c:IsDescendantOf(ws.Map) then
                    pcall(c.Destroy, c)
                end
            end
        end
    end

    if ws:FindFirstChild("Entities") then
        cleanup(ws.Entities)
    end
    ws.ChildAdded:Connect(cleanup)
end)
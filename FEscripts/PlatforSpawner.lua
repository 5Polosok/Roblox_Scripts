local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local ENABLED = false
local PLATFORMS = {}
local PLATFORM_SIZE = Vector3.new(4, 0.1, 4)
local PLATFORM_MATERIAL = Enum.Material.Neon
local PLATFORM_COLOR = Color3.fromRGB(0, 255, 255)
local LAST_PLATFORM_TIME = 0
local COOLDOWN = 0.2
local HEIGHT_THRESHOLD = 50 -- Высота, при превышении которой платформы спавнятся ниже
local PLATFORM_OFFSET_BELOW = 10 -- Насколько ниже спавнить платформы при высокой высоте

-- Функция для очистки платформ
local function clearPlatforms()
    for _, platform in pairs(PLATFORMS) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    PLATFORMS = {}
end

-- Проверка возможности размещения платформы
local function canPlacePlatform(position)
    local rayOrigin = position + Vector3.new(0, 5, 0)
    local rayDirection = Vector3.new(0, -10, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return not raycastResult
end

-- Проверка, находится ли игрок в воздухе
local function isInAir()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = Workspace:Raycast(RootPart.Position, Vector3.new(0, -5, 0), raycastParams)
    return not raycastResult
end

-- Создание платформы
local function createPlatform(position)
    if not canPlacePlatform(position) then return end
    
    local platform = Instance.new("Part")
    platform.Anchored = true
    platform.CanCollide = true
    platform.Size = PLATFORM_SIZE
    platform.Material = PLATFORM_MATERIAL
    platform.Color = PLATFORM_COLOR
    platform.Transparency = 0.5
    platform.Position = position
    platform.Parent = Workspace
    
    -- Автоудаление платформы через 10 секунд
    delay(10, function()
        if platform and platform.Parent then
            platform:Destroy()
        end
    end)
    
    table.insert(PLATFORMS, platform)
    return platform
end

-- Определение позиции для платформы
local function getPlatformPosition()
    local currentHeight = RootPart.Position.Y
    
    if currentHeight > HEIGHT_THRESHOLD then
        -- Если выше пороговой высоты, спавним платформу значительно ниже
        return Vector3.new(
            RootPart.Position.X,
            HEIGHT_THRESHOLD - PLATFORM_OFFSET_BELOW,
            RootPart.Position.Z
        )
    else
        -- Иначе спавним платформу как обычно (на 3 единицы ниже игрока)
        return RootPart.Position - Vector3.new(0, 3, 0)
    end
end

-- Обработка ввода
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        ENABLED = not ENABLED
        print("Автоплатформы: " .. (ENABLED and "ВКЛ" or "ВЫКЛ"))
    elseif input.KeyCode == Enum.KeyCode.R then
        clearPlatforms()
    end
end)

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if not ENABLED or not RootPart or not isInAir() then return end
    if os.clock() - LAST_PLATFORM_TIME < COOLDOWN then return end
    
    local platformPosition = getPlatformPosition()
    createPlatform(platformPosition)
    LAST_PLATFORM_TIME = os.clock()
end)

-- Обновление ссылок на персонажа при его изменении
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    RootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

print("Скрипт запущен! F - вкл/выкл, R - очистить платформы")
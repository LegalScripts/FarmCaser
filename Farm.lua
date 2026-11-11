local CoreGui = game:GetService("CoreGui")
local success = pcall(function() local _ = CoreGui.Name end)
local targetGui = success and CoreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

if targetGui:FindFirstChild("AntiCheatTestMenu") then
    targetGui.AntiCheatTestMenu:Destroy()
end

local autoFarm = false
local cooldown = 4

-- Список слов или символов-триггеров для сохранения
local keepItems = {
    "★", 
    "Navaja Knife", 
    "Kukri Knife", 
    "Paracord Knife"
}

-- Создаем главное окно
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiCheatTestMenu"
ScreenGui.Parent = targetGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "🛠 Тест Античита v5 (Точный)"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Автофарм: ВЫКЛ"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = MainFrame

local CooldownBox = Instance.new("TextBox")
CooldownBox.Size = UDim2.new(0.9, 0, 0, 30)
CooldownBox.Position = UDim2.new(0.05, 0, 0.65, 0)
CooldownBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CooldownBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CooldownBox.Text = tostring(cooldown)
CooldownBox.PlaceholderText = "Кулдаун (сек)"
CooldownBox.Font = Enum.Font.SourceSans
CooldownBox.TextSize = 16
CooldownBox.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    if autoFarm then
        ToggleBtn.Text = "Автофарм: ВКЛ"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ToggleBtn.Text = "Автофарм: ВЫКЛ"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

CooldownBox.FocusLost:Connect(function()
    local num = tonumber(CooldownBox.Text)
    if num then cooldown = num else CooldownBox.Text = tostring(cooldown) end
end)

-- Функция: проверяет, действительно ли элемент виден на экране (включая всех родителей)
local function isTrulyVisible(guiObj)
    if not guiObj:IsA("GuiObject") or not guiObj.Visible then return false end
    local parent = guiObj.Parent
    while parent and parent ~= game do
        if parent:IsA("GuiObject") and not parent.Visible then
            return false
        end
        if parent:IsA("ScreenGui") and not parent.Enabled then
            return false
        end
        parent = parent.Parent
    end
    return true
end

-- Функция проверки наличия кнопки на экране
local function isButtonVisible(exactKeyword)
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, guiObj in pairs(playerGui:GetDescendants()) do
        if (guiObj:IsA("TextButton") or guiObj:IsA("TextLabel")) and isTrulyVisible(guiObj) then
            if guiObj.Text and string.find(guiObj.Text, exactKeyword) then
                return true
            end
        end
    end
    return false
end

-- Функция для клика
local function clickButtonByText(exactKeyword)
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, guiObj in pairs(playerGui:GetDescendants()) do
        if (guiObj:IsA("TextButton") or guiObj:IsA("TextLabel")) and isTrulyVisible(guiObj) then
            if guiObj.Text and string.find(guiObj.Text, exactKeyword) then
                local button = guiObj
                if guiObj:IsA("TextLabel") and guiObj.Parent:IsA("GuiButton") then
                    button = guiObj.Parent
                end
                
                if button:IsA("GuiButton") then
                    if getconnections then
                        for _, connection in pairs(getconnections(button.MouseButton1Click)) do connection:Fire() end
                        for _, connection in pairs(getconnections(button.MouseButton1Down)) do connection:Fire() end
                        for _, connection in pairs(getconnections(button.Activated)) do connection:Fire() end
                        return true
                    elseif firesignal then
                        firesignal(button.MouseButton1Click)
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ТОЧНОЕ СКАНИРОВАНИЕ: только центр экрана (без левой панели и без нижней ленты шансов)
local function checkForValuableItems()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local camera = workspace.CurrentCamera
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    
    for _, guiObj in pairs(playerGui:GetDescendants()) do
        if guiObj:IsA("TextLabel") and isTrulyVisible(guiObj) then
            local posX = guiObj.AbsolutePosition.X
            local posY = guiObj.AbsolutePosition.Y
            
            -- 1. Отсекаем левые 22% (инвентарь)
            -- 2. Отсекаем верхние 12% (шапка меню) и нижние 30% (лента возможных призов внизу)
            if posX > (screenWidth * 0.22) and posY > (screenHeight * 0.12) and posY < (screenHeight * 0.70) then
                for _, keepWord in ipairs(keepItems) do
                    if guiObj.Text and string.find(guiObj.Text, keepWord) then
                        return true, guiObj.Text
                    end
                end
            end
        end
    end
    return false, nil
end

-- Основной цикл
task.spawn(function()
    while task.wait(0.1) do
        if autoFarm then
            local clickedOpen = clickButtonByText("ОТКРЫТЬ БЕСПЛАТНО")
            
            if clickedOpen then
                -- Даем 1.5 секунды на начало прокрутки (чтобы старая кнопка продажи успела исчезнуть)
                task.wait(1.5)
                
                local uiAppeared = false
                local timeWaited = 1.5
                local timeout = 15
                
                while not uiAppeared and timeWaited < timeout do
                    task.wait(0.2)
                    timeWaited = timeWaited + 0.2
                    if not autoFarm then break end 
                    
                    uiAppeared = isButtonVisible("ПРОДАТЬ ВСЁ")
                end
                
                if uiAppeared then
                    -- Небольшая пауза, чтобы текст выпавших предметов успел обновиться
                    task.wait(0.3)
                    
                    local isValuable, itemName = checkForValuableItems()
                    
                    if isValuable then
                        print("🎉 ВЫПАЛ ЦЕННЫЙ ПРЕДМЕТ В ЦЕНТРЕ: " .. itemName .. ". Продажа отменена!")
                    else
                        clickButtonByText("ПРОДАТЬ ВСЁ")
                        print("♻️ Обычный дроп продан.")
                    end
                else
                    warn("⏳ ОШИБКА: Кнопка 'ПРОДАТЬ ВСЁ' не появилась.")
                end
                
                local remainingCooldown = math.max(cooldown - timeWaited, 0.5)
                task.wait(remainingCooldown)
            end
        end
    end
end)

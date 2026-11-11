-- Попытка использовать CoreGui (безопасно для эксплойтов) или PlayerGui (фоллбэк)
local CoreGui = game:GetService("CoreGui")
local success = pcall(function() local _ = CoreGui.Name end)
local targetGui = success and CoreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старое меню, если скрипт перезапускается
if targetGui:FindFirstChild("AntiCheatTestMenu") then
    targetGui.AntiCheatTestMenu:Destroy()
end

local autoFarm = false
local cooldown = 4

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
MainFrame.Draggable = true -- Делает окно перемещаемым мышью
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "🛠 Тест Античита"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.BorderSizePixel = 0
Title.Parent = MainFrame

-- Кнопка Вкл/Выкл
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Автофарм: ВЫКЛ"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = MainFrame

-- Поле ввода кулдауна
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

-- Логика интерфейса
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
    if num then
        cooldown = num
    else
        -- Возвращаем старое значение, если ввели не число
        CooldownBox.Text = tostring(cooldown)
    end
end)

-- Функция клика
local function clickButtonByText(keyword)
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, guiObj in pairs(playerGui:GetDescendants()) do
        if guiObj:IsA("TextButton") or guiObj:IsA("TextLabel") then
            local text = string.lower(guiObj.Text)
            if string.find(text, string.lower(keyword)) then
                local button = guiObj
                if guiObj:IsA("TextLabel") and guiObj.Parent:IsA("GuiButton") then
                    button = guiObj.Parent
                end
                
                if button:IsA("GuiButton") then
                    if getconnections then
                        for _, connection in pairs(getconnections(button.MouseButton1Click)) do connection:Fire() end
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

-- Основной цикл
task.spawn(function()
    while task.wait(0.1) do
        if autoFarm then
            clickButtonByText("открыть бесплатно")
            
            task.wait(1)
            
            -- Проверяем, не выключили ли фарм во время ожидания
            if not autoFarm then continue end 
            
            clickButtonByText("продать всё")
            
            -- Ждем заданный кулдаун минус 1 секунду
            local waitTime = math.max(cooldown - 1, 0)
            task.wait(waitTime)
        end
    end
end)

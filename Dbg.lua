local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Флаг работы авто-респавна
local isAutoRespawnActive = false
game:GetService("Players").RespawnTime = 0.01

-- Создание интерфейса (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestControlUI"
screenGui.ResetOnSpawn = false -- UI сохраняется при респавне
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Главная рамка
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 220)
mainFrame.Position = UDim2.new(0, 20, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Перетаскивание панельки
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleLabel.Text = "Studio Test Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Поле ввода X, Y, Z
local posInput = Instance.new("TextBox")
posInput.Size = UDim2.new(0.9, 0, 0, 30)
posInput.Position = UDim2.new(0.05, 0, 0.2, 0)
posInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
posInput.Text = "0, 10, 0"
posInput.PlaceholderText = "X, Y, Z"
posInput.TextColor3 = Color3.fromRGB(255, 255, 255)
posInput.TextSize = 14
posInput.Font = Enum.Font.SourceSans
posInput.Parent = mainFrame

-- Кнопка считывания текущих координат
local getPosButton = Instance.new("TextButton")
getPosButton.Size = UDim2.new(0.9, 0, 0, 30)
getPosButton.Position = UDim2.new(0.05, 0, 0.38, 0)
getPosButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
getPosButton.Text = "📍 Взять координаты HRP"
getPosButton.TextColor3 = Color3.fromRGB(255, 255, 255)
getPosButton.TextSize = 13
getPosButton.Font = Enum.Font.SourceSans
getPosButton.Parent = mainFrame

-- Кнопка старта / стопа
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 40)
toggleButton.Position = UDim2.new(0.05, 0, 0.58, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.Text = "Авто-респавн: ВЫКЛ"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainFrame

-- Парсинг координат из поля ввода
local function getTargetVector()
	local coords = {}
	for num in string.gmatch(posInput.Text, "[%d%.%-]+") do
		table.insert(coords, tonumber(num))
	end
	if #coords >= 3 then
		return Vector3.new(coords[1], coords[2], coords[3])
	end
	return Vector3.new(0, 10, 0)
end

-- Обработка кнопки «Взять координаты»
getPosButton.MouseButton1Click:Connect(function()
	local character = localPlayer.Character
	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local pos = rootPart.Position
			-- Округляем до 1 знака после запятой для чистоты текста
			local formatted = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
			posInput.Text = formatted
		end
	end
end)

-- Основная логика телепорта и сброса
local function onCharacterAdded(character)
	if not isAutoRespawnActive then return end
	
	local rootPart = character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not rootPart or not humanoid then return end

	task.wait(0.1)
	
	if isAutoRespawnActive then
		local targetPos = getTargetVector()
		character:PivotTo(CFrame.new(targetPos))
		
		task.wait(1)
		
		if isAutoRespawnActive and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end
end

-- Переключение авто-респавна
toggleButton.MouseButton1Click:Connect(function()
	isAutoRespawnActive = not isAutoRespawnActive
	
	if isAutoRespawnActive then
		toggleButton.Text = "Авто-респавн: ВКЛ"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
		
		if localPlayer.Character then
			task.spawn(function()
				onCharacterAdded(localPlayer.Character)
			end)
		end
	else
		toggleButton.Text = "Авто-респавн: ВЫКЛ"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)

localPlayer.CharacterAdded:Connect(onCharacterAdded)

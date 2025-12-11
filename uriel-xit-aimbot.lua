-- URIEL XIT AIMBOT - Versão Final (Só mira com Aimbot ON + Botão Direito)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Cam = workspace.CurrentCamera
local AimbotEnabled = false  -- Botão Aimbot ON/OFF
local MaxDistance = 300
local FOVRadius = 150
local Smoothness = 0.2
local TeamCheck = false
local ESPEnabled = true
local ESPRGBEnabled = true
local PanelVisible = true
local IsHoldingRMB = false

-- Variáveis RGB
local hue = 0
local espHue = 0
local rgbSpeed = 0.5
local highlights = {}

-- Interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UrielXitUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FOV Circle
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, FOVRadius*2, 0, FOVRadius*2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Parent = screenGui

local circleStroke = Instance.new("UIStroke")
circleStroke.Thickness = 2
circleStroke.Color = Color3.fromHSV(hue, 1, 1)
circleStroke.Transparency = 0.5
circleStroke.Parent = fovCircle
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

-- Painel Principal
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 300, 0, 270)
panel.Position = UDim2.new(0, 20, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
panel.BackgroundTransparency = 0.05
panel.Active = true
panel.Draggable = true
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 2
panelStroke.Color = Color3.fromRGB(40, 40, 50)
panelStroke.Parent = panel

-- Sombra
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = panel

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundTransparency = 1
title.Text = "URIEL XIT"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextStrokeTransparency = 0.7
title.Parent = panel

-- Divisor
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.9, 0, 0, 1)
divider.Position = UDim2.new(0.05, 0, 0, 30)
divider.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
divider.BorderSizePixel = 0
divider.Parent = panel

-- Botão Aimbot (ON/OFF DO AIMBOT)
local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Size = UDim2.new(0.9, 0, 0, 36)
aimbotBtn.Position = UDim2.new(0.05, 0, 0, 38)
aimbotBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
aimbotBtn.Text = "Aimbot: OFF (Segure RMB para mirar)"
aimbotBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
aimbotBtn.Font = Enum.Font.GothamMedium
aimbotBtn.TextSize = 14
aimbotBtn.Parent = panel
Instance.new("UICorner", aimbotBtn).CornerRadius = UDim.new(0, 8)

local aimbotStroke = Instance.new("UIStroke")
aimbotStroke.Thickness = 1.5
aimbotStroke.Color = Color3.fromRGB(70, 70, 85)
aimbotStroke.Parent = aimbotBtn

-- Funções auxiliares
local function CreateInput(y, text, value)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 0, 24)
    label.Position = UDim2.new(0.05, 0, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = panel
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.4, 0, 0, 24)
    box.Position = UDim2.new(0.55, 0, 0, y)
    box.Text = tostring(value)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    box.TextColor3 = Color3.fromRGB(220, 220, 230)
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.Parent = panel
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1
    boxStroke.Color = Color3.fromRGB(60, 60, 75)
    boxStroke.Parent = box
    
    return box
end

local function CreateToggle(y, text, initialState, isESP, isRGB)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = initialState and (isRGB and Color3.fromRGB(100, 0, 100) or Color3.fromRGB(0, 80, 0)) or Color3.fromRGB(35, 35, 45)
    btn.Text = text .. (initialState and ": ON" or ": OFF")
    btn.TextColor3 = isESP and Color3.fromRGB(255, 255, 200) or Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = panel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Color = initialState and (isRGB and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(0, 180, 0)) or Color3.fromRGB(70, 70, 85)
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = initialState and (isRGB and Color3.fromRGB(100, 0, 100) or Color3.fromRGB(0, 80, 0)) or Color3.fromRGB(35, 35, 45)
    end)
    
    return btn, btnStroke
end

-- Inputs
local fovInput = CreateInput(85, "FOV:", FOVRadius)
local distInput = CreateInput(115, "Distância:", MaxDistance)

-- Botões Toggle
local teamBtn, teamStroke = CreateToggle(150, "Team Check", TeamCheck, false, false)
local espBtn, espStroke = CreateToggle(185, "ESP Branco", ESPEnabled, true, false)
local rgbBtn, rgbStroke = CreateToggle(220, "ESP RGB", ESPRGBEnabled, true, true)

-- Sistema de Aimbot
local function GetHead(char)
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function IsValidTarget(player)
    if not player or player == LocalPlayer then return false end
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local head = GetHead(char)
    if not head then return false end
    if not Cam then return false end
    local distance = (head.Position - Cam.CFrame.Position).Magnitude
    if distance > MaxDistance then return false end
    if TeamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return false end
    return true
end

local function GetClosestTarget()
    if not Cam then return nil end
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local bestTarget, bestDistance = nil, math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local head = GetHead(player.Character)
            if head then
                local screenPos, visible = Cam:WorldToViewportPoint(head.Position)
                if visible then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if distance < bestDistance and distance <= FOVRadius then
                        bestTarget, bestDistance = player, distance
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function AimAt(target, instant)
    if not Cam or not target or not target.Character then return end
    local head = GetHead(target.Character)
    if not head then return end
    local look = CFrame.new(Cam.CFrame.Position, head.Position)
    if instant then
        Cam.CFrame = look
    else
        Cam.CFrame = Cam.CFrame:Lerp(look, math.clamp(Smoothness, 0, 1))
    end
end

-- Sistema ESP
local function CreateHighlight(player, character)
    if not character or not ESPEnabled then return end
    if highlights[player] then
        pcall(function() highlights[player]:Destroy() end)
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "UrielESP"
    highlight.Adornee = character
    
    if ESPRGBEnabled then
        local color = Color3.fromHSV(espHue, 1, 1)
        highlight.FillColor = color
        highlight.OutlineColor = color
    else
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(200, 200, 200)
    end
    
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.4
    highlight.Parent = character
    highlights[player] = highlight
end

local function RemoveHighlight(player)
    local highlight = highlights[player]
    if highlight then pcall(function() highlight:Destroy() end) end
    highlights[player] = nil
end

local function SetupESP(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        if ESPEnabled then
            CreateHighlight(player, character)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        SetupESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        SetupESP(player)
    end
end)

local function EnableAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateHighlight(player, player.Character)
        end
    end
end

local function DisableAllESP()
    for player, highlight in pairs(highlights) do
        if highlight then pcall(function() highlight:Destroy() end) end
    end
    highlights = {}
end

local function UpdateESPColors()
    if ESPEnabled and ESPRGBEnabled then
        for player, highlight in pairs(highlights) do
            if highlight and highlight:IsDescendantOf(game) then
                local color = Color3.fromHSV(espHue, 1, 1)
                highlight.FillColor = color
                highlight.OutlineColor = color
            end
        end
    end
end

-- Input Handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Botão direito do mouse
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsHoldingRMB = true
    end
    
    -- Tecla F1
    if input.KeyCode == Enum.KeyCode.F1 then
        PanelVisible = not PanelVisible
        panel.Visible = PanelVisible
        shadow.Visible = PanelVisible
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsHoldingRMB = false
    end
end)

-- Botão Aimbot (ON/OFF)
aimbotBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    aimbotBtn.Text = AimbotEnabled and "Aimbot: ON (Segure RMB para mirar)" or "Aimbot: OFF (Segure RMB para mirar)"
    aimbotBtn.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(35, 35, 45)
    aimbotStroke.Color = AimbotEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
    
    aimbotBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    task.wait(0.1)
    aimbotBtn.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(35, 35, 45)
end)

-- Botão Team Check
teamBtn.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    teamBtn.Text = "Team Check" .. (TeamCheck and ": ON" or ": OFF")
    teamBtn.BackgroundColor3 = TeamCheck and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(35, 35, 45)
    teamStroke.Color = TeamCheck and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
    
    teamBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    task.wait(0.1)
    teamBtn.BackgroundColor3 = TeamCheck and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(35, 35, 45)
end)

-- Botão ESP Branco
espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espBtn.Text = "ESP Branco" .. (ESPEnabled and ": ON" or ": OFF")
    espBtn.BackgroundColor3 = ESPEnabled and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(35, 35, 45)
    espStroke.Color = ESPEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
    
    if ESPEnabled then
        EnableAllESP()
    else
        DisableAllESP()
        if ESPRGBEnabled then
            ESPRGBEnabled = false
            rgbBtn.Text = "ESP RGB: OFF"
            rgbBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            rgbStroke.Color = Color3.fromRGB(70, 70, 85)
        end
    end
    
    espBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    task.wait(0.1)
    espBtn.BackgroundColor3 = ESPEnabled and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(35, 35, 45)
end)

-- Botão ESP RGB
rgbBtn.MouseButton1Click:Connect(function()
    ESPRGBEnabled = not ESPRGBEnabled
    rgbBtn.Text = "ESP RGB" .. (ESPRGBEnabled and ": ON" or ": OFF")
    rgbBtn.BackgroundColor3 = ESPRGBEnabled and Color3.fromRGB(100, 0, 100) or Color3.fromRGB(35, 35, 45)
    rgbStroke.Color = ESPRGBEnabled and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(70, 70, 85)
    
    if ESPRGBEnabled and not ESPEnabled then
        ESPEnabled = true
        espBtn.Text = "ESP Branco: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
        espStroke.Color = Color3.fromRGB(0, 180, 0)
        EnableAllESP()
    end
    
    if ESPEnabled then
        UpdateESPColors()
    end
    
    rgbBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    task.wait(0.1)
    rgbBtn.BackgroundColor3 = ESPRGBEnabled and Color3.fromRGB(100, 0, 100) or Color3.fromRGB(35, 35, 45)
end)

-- Atualizar FOV
fovInput.FocusLost:Connect(function()
    local newValue = tonumber(fovInput.Text)
    if newValue and newValue > 20 and newValue < 2000 then
        FOVRadius = newValue
        fovCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
    else
        fovInput.Text = tostring(FOVRadius)
    end
end)

-- Atualizar Distância
distInput.FocusLost:Connect(function()
    local newValue = tonumber(distInput.Text)
    if newValue and newValue > 50 and newValue < 100000 then
        MaxDistance = newValue
    else
        distInput.Text = tostring(MaxDistance)
    end
end)

-- Texto Informativo F1
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, 0, 0, 20)
infoText.Position = UDim2.new(0, 0, 0, 5)
infoText.BackgroundTransparency = 1
infoText.Text = "Pressione F1 para mostrar/esconder o painel"
infoText.TextColor3 = Color3.fromRGB(150, 150, 150)
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11
infoText.Visible = false
infoText.Parent = screenGui

task.spawn(function()
    infoText.Visible = true
    task.wait(5)
    infoText.Visible = false
end)

-- Loop Principal - LÓGICA CORRIGIDA AQUI
RunService.RenderStepped:Connect(function(deltaTime)
    -- Atualizar cores RGB (sempre)
    hue = (hue + rgbSpeed * deltaTime) % 1
    circleStroke.Color = Color3.fromHSV(hue, 1, 1)
    
    if ESPRGBEnabled then
        espHue = (espHue + rgbSpeed * deltaTime * 0.8) % 1
        UpdateESPColors()
    end
    
    if not Cam then Cam = workspace.CurrentCamera end
    
    -- CONDIÇÃO PRINCIPAL: Só mira se AMBOS forem verdade
    -- 1. Aimbot precisa estar ON
    -- 2. E precisa estar segurando botão direito
    
    if not AimbotEnabled then
        -- Aimbot OFF: FOV transparente, nunca mira
        circleStroke.Transparency = 0.8
        return
    end
    
    -- Aimbot está ON, mas sem botão direito? Mostra FOV mas não mira
    if not IsHoldingRMB then
        circleStroke.Transparency = 0.5  -- FOV visível
        return
    end
    
    -- Aimbot ON + Botão Direito pressionado = AGORA SIM MIRA!
    local target = GetClosestTarget()
    if target then
        AimAt(target, true)  -- Mira instantaneamente
        circleStroke.Transparency = 0.2  -- FOV bem visível (encontrou alvo)
    else
        circleStroke.Transparency = 0.5  -- FOV visível mas sem alvo
    end
end)

-- Inicializar ESP
task.wait(1)
EnableAllESP()

print("🎯 Uriel Xit Aimbot carregado!")
print("📌 Funcionamento CORRETO:")
print("   1. Clique em 'Aimbot: OFF' para ligar (vira 'Aimbot: ON')")
print("   2. Segure Botão DIREITO do mouse para mirar")
print("   3. Solte o botão para parar de mirar")
print("   4. F1 para mostrar/esconder painel")
print("")
print("✅ Aimbot só funciona quando:")
print("   • Aimbot está ON")
print("   • E está segurando botão direito")

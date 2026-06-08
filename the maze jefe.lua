-- Limpieza estricta de interfaces duplicadas
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)

if _G.JefeMenuCargado then
    pcall(function() PlayerGui:FindFirstChild("JefeScriptsUI"):Destroy() end)
    if shared.CleanMazeESP then shared.CleanMazeESP() end
end
_G.JefeMenuCargado = true

-- Variables de control para los Toggles
_G.ESP_Lineas = false
_G.ESP_Distancia = false
_G.ESP_Holograma = false
_G.NoClip = false
_G.FullBright = false

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- INTERFAZ PRINCIPAL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JefeScriptsUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- 1. BOTÓN FLOTANTE OVALADO (Estilo Rayfield "Show/Hide")
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatBtn"
FloatBtn.Parent = ScreenGui
FloatBtn.Size = UDim2.new(0, 130, 0, 35)
FloatBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FloatBtn.Text = "JEFE SCRIPT"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.SourceSansBold
FloatBtn.TextSize = 15
FloatBtn.ZIndex = 10

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 18) -- Ovalado perfecto
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 255, 50) -- Borde verde neón
FloatStroke.Thickness = 1.5
FloatStroke.Parent = FloatBtn

-- Hacer el botón flotante arrastrable
local dragging, dragInput, dragStart, startPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = FloatBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
FloatBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 2. CONTENEDOR DE LA INTERFAZ (Tu diseño)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.Visible = false
MainFrame.ZIndex = 5

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 50, 50) -- Borde Rojo de tu dibujo
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Abrir / Cerrar
FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 3. ENCABEZADO SUPERIOR VERDE
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.Size = UDim2.new(1, -40, 0, 38)
Header.Position = UDim2.new(0, 20, 0, -15) -- Sobresale arriba
Header.BackgroundColor3 = Color3.fromRGB(0, 150, 30)
Header.ZIndex = 6

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "JEFE SCRIPTS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.ZIndex = 7

-- 4. COLUMNA IZQUIERDA (Pestañas hacia abajo)
local LeftPanel = Instance.new("Frame")
LeftPanel.Parent = MainFrame
LeftPanel.Size = UDim2.new(0, 140, 1, -45)
LeftPanel.Position = UDim2.new(0, 10, 0, 35)
LeftPanel.BackgroundTransparency = 1
LeftPanel.ZIndex = 6

local LeftList = Instance.new("UIListLayout")
LeftList.Parent = LeftPanel
LeftList.SortOrder = Enum.SortOrder.LayoutOrder
LeftList.Padding = UDim.new(0, 8)

-- 5. LÍNEA VERDE DIVISORIA CENTRAL
local DivLine = Instance.new("Frame")
DivLine.Parent = MainFrame
DivLine.Size = UDim2.new(0, 3, 1, -50)
DivLine.Position = UDim2.new(0, 155, 0, 35)
DivLine.BackgroundColor3 = Color3.fromRGB(0, 255, 50)
DivLine.BorderSizePixel = 0
DivLine.ZIndex = 6

-- 6. COLUMNA DERECHA (Contenedor de Opciones con Scroll)
local RightPanel = Instance.new("Frame")
RightPanel.Parent = MainFrame
RightPanel.Size = UDim2.new(1, -175, 1, -45)
RightPanel.Position = UDim2.new(0, 165, 0, 35)
RightPanel.BackgroundTransparency = 1
RightPanel.ZIndex = 6

local function CrearContenedorPagina()
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0, 0, 0, 350)
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 50)
    Page.Visible = false
    Page.ZIndex = 7
    
    local List = Instance.new("UIListLayout")
    List.Parent = Page
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0, 6)
    
    return Page
end

local PaginaVisuales = CrearContenedorPagina() PaginaVisuales.Parent = RightPanel PaginaVisuales.Visible = true
local PaginaHacks = CrearContenedorPagina() PaginaHacks.Parent = RightPanel
local PaginaHerramientas = CrearContenedorPagina() PaginaHerramientas.Parent = RightPanel
local PaginaMenusTP = CrearContenedorPagina() PaginaMenusTP.Parent = RightPanel

-- 7. GENERADOR DE PESTAÑAS BLANCAS
local function CrearBotonPestaña(texto, paginaAsociada)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = texto
    Btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Parent = LeftPanel
    Btn.ZIndex = 7
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        PaginaVisuales.Visible = false; PaginaHacks.Visible = false; PaginaHerramientas.Visible = false; PaginaMenusTP.Visible = false
        paginaAsociada.Visible = true
    end)
end

CrearBotonPestaña("VISUALES", PaginaVisuales)
CrearBotonPestaña("HACKS", PaginaHacks)
CrearBotonPestaña("HERRAMIENTAS", PaginaHerramientas)
CrearBotonPestaña("MENUS TP", PaginaMenusTP)

-- 8. GENERADOR DE INTERRUPTORES (TOGGLES)
local function CrearToggle(nombre, pagina, callback)
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(1, -5, 0, 36)
    Box.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Box.Parent = pagina
    Box.ZIndex = 7
    
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = nombre
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Box
    Label.ZIndex = 8
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 35, 0, 18)
    Switch.Position = UDim2.new(1, -45, 0.5, -9)
    Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Switch.Text = ""
    Switch.Parent = Box
    Switch.ZIndex = 8
    
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 9)
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 12, 0, 12)
    Dot.Position = UDim2.new(0, 3, 0.5, -6)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.Parent = Switch
    Dot.ZIndex = 9
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(0, 6)
    
    local activo = false
    Switch.MouseButton1Click:Connect(function()
        activo = not activo
        if activo then
            TweenService:Create(Switch, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(0, 255, 50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.12), {Position = UDim2.new(1, -15, 0.5, -6)}):Play()
        else
            TweenService:Create(Switch, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.12), {Position = UDim2.new(0, 3, 0.5, -6)}):Play()
        end
        callback(activo)
    end)
end

-- Rellenar las opciones en cada pestaña
CrearToggle("ESP Línea Moster", PaginaVisuales, function(v) _G.ESP_Lineas = v end)
CrearToggle("ESP Distancia Moster", PaginaVisuales, function(v) _G.ESP_Distancia = v end)
CrearToggle("ESP Holograma Arcoíris 🌈", PaginaVisuales, function(v) _G.ESP_Holograma = v end)

CrearToggle("Atravesar Paredes (NoClip)", PaginaHacks, function(v) _G.NoClip = v end)
CrearToggle("Sprint Infinito (Slot)", PaginaHacks, function() end)

CrearToggle("Luz Global / FullBright", PaginaHerramientas, function(v)
    _G.FullBright = v
    game:GetService("Lighting").Ambient = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
end)

CrearToggle("Teletransportar al Lobby (Slot)", PaginaMenusTP, function() end)

---------------------------------------------------------
-- 👁️ MOTOR DE RENDERIZADO (ESP THE MAZE NATIVO)
---------------------------------------------------------
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local MonsterNames = { ["Orotund"] = true, ["The Cajoler"] = true, ["Creptus"] = true }
local ActiveESPs = {}

local function getRainbowColor() return Color3.fromHSV((tick() * 1) % 1, 1, 1) end
local function getDistanceColor(d)
    if d < 45 then return Color3.fromRGB(255, 0, 0)
    elseif d < 120 then return Color3.fromRGB(255, 215, 0)
    else return Color3.fromRGB(0, 255, 100) end
end

local function removeESP(model)
    if ActiveESPs[model] then
        pcall(function()
            if ActiveESPs[model].Line then ActiveESPs[model].Line:Remove() end
            if ActiveESPs[model].Text then ActiveESPs[model].Text:Remove() end
            if ActiveESPs[model].Highlight then ActiveESPs[model].Highlight:Destroy() end
        end)
        ActiveESPs[model] = nil
    end
end

local function createESP(model)
    if ActiveESPs[model] then return end
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end

    local line = Drawing.new("Line")
    line.Thickness = 2.5; line.Transparency = 1; line.Visible = false

    local text = Drawing.new("Text")
    text.Size = 15; text.Center = true; text.Outline = true; text.OutlineColor = Color3.fromRGB(0, 0, 0); text.Visible = false

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.4; highlight.OutlineTransparency = 0.1; highlight.Adornee = model; highlight.Enabled = false; highlight.Parent = model

    ActiveESPs[model] = { Line = line, Text = text, Highlight = highlight, Root = rootPart }
end

RunService.RenderStepped:Connect(function()
    for _, obj in ipairs(workspace:GetChildren()) do
        if MonsterNames[obj.Name] and obj:IsA("Model") then createESP(obj) end
    end

    local char = LocalPlayer.Character
    if _G.NoClip and char then
        for _, child in pairs(char:GetDescendants()) do
            if child:IsA("BasePart") then child.CanCollide = false end
        end
    end

    for model, esp in pairs(ActiveESPs) do
        if not model:IsDescendantOf(workspace) or not esp.Root then removeESP(model); continue end
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")

        if myRoot then
            local monsterPos = esp.Root.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(monsterPos)
            local distance = (myRoot.Position - monsterPos).Magnitude

            if _G.ESP_Holograma then
                local rainbow = getRainbowColor()
                esp.Highlight.Enabled = true; esp.Highlight.FillColor = rainbow; esp.Highlight.OutlineColor = rainbow
            else esp.Highlight.Enabled = false end

            if onScreen then
                local dynamicColor = getDistanceColor(distance)
                if _G.ESP_Lineas then
                    esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Line.To = Vector2.new(screenPos.X, screenPos.Y); esp.Line.Color = dynamicColor; esp.Line.Visible = true
                else esp.Line.Visible = false end

                if _G.ESP_Distancia then
                    esp.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                    esp.Text.Text = string.format("[%s]\n%d m", model.Name:upper(), distance); esp.Text.Color = dynamicColor; esp.Text.Visible = true
                else esp.Text.Visible = false end
            else esp.Line.Visible = false; esp.Text.Visible = false end
        else esp.Line.Visible = false; esp.Text.Visible = false end
    end
end)

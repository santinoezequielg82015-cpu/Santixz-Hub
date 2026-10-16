-- ============================================================
-- SANTIXZ HUB | Steal An Egg | Admin Abuse Minigames
-- Versión extendida con ESP, HUD, Auto-Steal, Admin Abuse,
-- Mini-juegos, Movement, Visuals, Player, Server, Misc
-- made by seraph
-- ============================================================

-- ============================================================
-- SERVICIOS
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- CONFIGURACIÓN GLOBAL
-- ============================================================
local Config = {
    -- ESP
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(0, 255, 100),
    ESPThickness = 2,
    ESPTransparency = 1,
    ESPShowDistance = true,
    ESPShowName = true,
    ESPShowValue = true,
    ESPMaxDistance = 500,
    ESPTracer = false,
    ESPBox = true,
    ESPChams = false,
    
    -- Auto-Steal
    AutoStealEnabled = false,
    AutoStealSpeed = 0.5,
    AutoStealMinValue = 1000000,
    AutoStealSelectedEgg = nil,
    AutoStealReturnToBase = true,
    AutoStealOnlyIfEmpty = true,
    AutoStealNotify = true,
    
    -- Velocidad
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    FlyEnabled = false,
    InfiniteJump = false,
    Noclip = false,
    SpeedBoost = false,
    
    -- HUD
    HUDEnabled = true,
    HUDColor = Color3.fromRGB(0, 255, 150),
    HUDPosition = UDim2.new(0, 10, 0.5, -60),
    
    -- Admin Abuse
    AdminAbuseEnabled = false,
    SelectedAdminMinigame = "Ninguno",
    AdminMinigameSpeed = 1,
    
    -- Mini-juegos
    AutoMinigame = false,
    MinigameAutoWin = false,
    MinigameSpeedHack = 1,
    
    -- Visuals
    Fullbright = true,
    NoFog = true,
    SkyboxRemove = false,
    AmbientColor = Color3.fromRGB(255, 255, 255),
    
    -- Player
    AntiAFK = true,
    AutoReconnect = true,
    InfiniteYield = false,
    
    -- Server
    ServerHop = false,
    RejoinServer = false,
}

-- ============================================================
-- BANNER / NOTIFICACIÓN DE CARGA
-- ============================================================
local function ShowBanner()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SantixzHub_Banner"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    
    local Banner = Instance.new("Frame")
    Banner.Size = UDim2.new(0, 400, 0, 100)
    Banner.Position = UDim2.new(0.5, -200, 0.4, -50)
    Banner.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Banner.BackgroundTransparency = 0.1
    Banner.BorderSizePixel = 0
    Banner.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Banner
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 255, 150)
    UIStroke.Thickness = 2
    UIStroke.Parent = Banner
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
    })
    Gradient.Parent = UIStroke
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "SANTIXZ HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = Banner
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0, 60)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Steal An Egg | Admin Abuse Edition"
    Subtitle.TextColor3 = Color3.fromRGB(0, 255, 150)
    Subtitle.TextScaled = true
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = Banner
    
    -- Animación de entrada
    Banner.Position = UDim2.new(0.5, -200, -0.3, -50)
    TweenService:Create(Banner, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -200, 0.4, -50)
    }):Play()
    
    task.wait(3)
    TweenService:Create(Banner, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -200, 1.3, -50)
    }):Play()
    task.wait(0.6)
    ScreenGui:Destroy()
end

-- ============================================================
-- INTERFAZ (Rayfield)
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Santixz Hub | Steal An Egg",
    LoadingTitle = "Cargando Santixz Hub...",
    LoadingSubtitle = "made by seraph",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SantixzHub_Config",
        FileName = "config"
    },
    KeySystem = false
})

-- ============================================================
-- MÓDULO ESP
-- ============================================================
local ESP = { Active = {}, Tracers = {} }

function ESP:CreateESP(object, text)
    if not object or not object:IsA("BasePart") then return end
    if self.Active[object] then return end
    
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Config.ESPColor
    Box.Thickness = Config.ESPThickness
    Box.Transparency = Config.ESPTransparency
    Box.Filled = false
    
    local Label = Drawing.new("Text")
    Label.Visible = false
    Label.Color = Config.ESPColor
    Label.Size = 14
    Label.Center = true
    Label.Outline = true
    Label.Text = text or object.Name
    
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Config.ESPColor
    Tracer.Thickness = 1
    Tracer.Transparency = 0.7
    
    self.Active[object] = {Box = Box, Label = Label, Tracer = Tracer}
end

function ESP:Update()
    for object, data in pairs(self.Active) do
        if not object or not object.Parent then
            if data.Box then data.Box:Remove() end
            if data.Label then data.Label:Remove() end
            if data.Tracer then data.Tracer:Remove() end
            self.Active[object] = nil
            continue
        end
        
        local position, onScreen = Camera:WorldToViewportPoint(object.Position)
        
        if onScreen and Config.ESPEnabled then
            local distance = (Camera.CFrame.Position - object.Position).Magnitude
            
            if distance <= Config.ESPMaxDistance then
                local size = math.clamp(2000 / distance, 10, 200)
                
                -- Caja
                if Config.ESPBox then
                    data.Box.Size = Vector2.new(size, size * 1.2)
                    data.Box.Position = Vector2.new(position.X - size/2, position.Y - size * 0.6)
                    data.Box.Color = Config.ESPColor
                    data.Box.Visible = true
                else
                    data.Box.Visible = false
                end
                
                -- Etiqueta
                local labelText = ""
                if Config.ESPShowName then labelText = object.Name end
                if Config.ESPShowDistance then
                    labelText = labelText .. (labelText ~= "" and " | " or "") .. math.floor(distance) .. "m"
                end
                
                data.Label.Text = labelText
                data.Label.Position = Vector2.new(position.X, position.Y + size * 0.7)
                data.Label.Color = Config.ESPColor
                data.Label.Visible = (Config.ESPShowName or Config.ESPShowDistance)
                
                -- Tracer
                if Config.ESPTracer then
                    data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    data.Tracer.To = Vector2.new(position.X, position.Y)
                    data.Tracer.Color = Config.ESPColor
                    data.Tracer.Visible = true
                else
                    data.Tracer.Visible = false
                end
            else
                data.Box.Visible = false
                data.Label.Visible = false
                data.Tracer.Visible = false
            end
        else
            data.Box.Visible = false
            data.Label.Visible = false
            data.Tracer.Visible = false
        end
    end
end

-- ============================================================
-- MÓDULO HUEVOS
-- ============================================================
local EggModule = { AllEggs = {}, SelectedEgg = nil }

function EggModule:ScanEggs()
    self.AllEggs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            if obj.Name:lower():find("egg") or obj.Name:lower():find("huevo") then
                table.insert(self.AllEggs, obj)
                ESP:CreateESP(obj:IsA("Model") and obj.PrimaryPart or obj, obj.Name)
            end
        end
    end
    return self.AllEggs
end

function EggModule:GetEggValue(egg)
    local value = egg:GetAttribute("Value") or egg:GetAttribute("Income") or 0
    if value == 0 then
        local nameValue = tonumber(egg.Name:match("%d+"))
        if nameValue then value = nameValue end
    end
    return value
end

-- ============================================================
-- MÓDULO AUTO-STEAL
-- ============================================================
local AutoSteal = { Running = false, Connection = nil, LastStealTime = 0, Count = 0 }

function AutoSteal:StealEgg(egg)
    if not egg or not egg.Parent then return false end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local root = character.HumanoidRootPart
    local distance = (root.Position - egg.Position).Magnitude
    
    if distance > 10 then
        root.CFrame = CFrame.new(egg.Position + Vector3.new(0, 3, 0))
        task.wait(0.1)
    end
    
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
    if prompt then fireproximityprompt(prompt) return true end
    
    local clickDetector = egg:FindFirstChildOfClass("ClickDetector")
    if clickDetector then fireclickdetector(clickDetector) return true end
    
    return false
end

function AutoSteal:FindBestEgg()
    local bestEgg, bestValue = nil, Config.AutoStealMinValue
    local eggs = EggModule:ScanEggs()
    for _, egg in ipairs(eggs) do
        local value = EggModule:GetEggValue(egg)
        if value >= bestValue then bestValue = value; bestEgg = egg end
    end
    return bestEgg
end

function AutoSteal:Start()
    if self.Running then return end
    self.Running = true
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Running then return end
        local currentTime = tick()
        if currentTime - self.LastStealTime < Config.AutoStealSpeed then return end
        self.LastStealTime = currentTime
        
        local targetEgg = nil
        if Config.AutoStealSelectedEgg then
            for _, egg in ipairs(EggModule.AllEggs) do
                if egg.Name == Config.AutoStealSelectedEgg then targetEgg = egg break end
            end
        else
            targetEgg = self:FindBestEgg()
        end
        
        if targetEgg then
            if self:StealEgg(targetEgg) then
                self.Count = self.Count + 1
                if Config.AutoStealNotify then
                    Rayfield:Notify({Title = "Robado", Content = targetEgg.Name, Duration = 1})
                end
            end
            if Config.AutoStealReturnToBase then
                task.wait(0.2)
                local spawnLocation = Workspace:FindFirstChildOfClass("SpawnLocation")
                if spawnLocation and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end)
end

function AutoSteal:Stop()
    self.Running = false
    if self.Connection then self.Connection:Disconnect() self.Connection = nil end
end

-- ============================================================
-- MÓDULO ADMIN ABUSE (Mini-juegos)
-- ============================================================
local AdminAbuse = { Active = false, Connection = nil }

-- Lista de mini-juegos comunes en admin abuse de Steal An Egg
local AdminMinigames = {
    "Ninguno",
    "Lluvia de Huevos",
    "Terremoto",
    "Congelar Jugadores",
    "Teletransporte Aleatorio",
    "Invertir Controles",
    "Gravedad Cero",
    "Gravedad Lunar",
    "Super Velocidad",
    "Cámara Loca",
    "Pantalla Giratoria",
    "Fuego en el Suelo",
    "Hielo Resbaladizo",
    "Modo Gigante",
    "Modo Enano",
    "Duplicar Jugadores",
    "Modo Fantasma",
    "Invisibilidad",
    "Confusión",
    "Ralentización",
}

function AdminAbuse:ExecuteMinigame(name)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    
    if name == "Lluvia de Huevos" then
        for i = 1, 20 do
            task.spawn(function()
                local egg = Instance.new("Part")
                egg.Name = "AdminEgg"
                egg.Shape = Enum.PartType.Ball
                egg.Size = Vector3.new(3, 3, 3)
                egg.Color = Color3.fromRGB(255, 255, 0)
                egg.Material = Enum.Material.Neon
                egg.Position = root.Position + Vector3.new(math.random(-50, 50), 100, math.random(-50, 50))
                egg.Parent = Workspace
                egg.CanCollide = true
                task.wait(math.random(1, 5))
                egg:Destroy()
            end)
        end
        
    elseif name == "Terremoto" then
        task.spawn(function()
            for i = 1, 60 do
                local offset = Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                root.CFrame = root.CFrame + offset
                task.wait(0.05)
            end
        end)
        
    elseif name == "Congelar Jugadores" then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local h = plr.Character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = 0 h.JumpPower = 0 end
            end
        end
        
    elseif name == "Teletransporte Aleatorio" then
        root.CFrame = CFrame.new(math.random(-500, 500), 50, math.random(-500, 500))
        
    elseif name == "Invertir Controles" then
        -- Simulación de inversión de controles
        for i = 1, 100 do
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
            task.wait(0.1)
        end
        
    elseif name == "Gravedad Cero" then
        Workspace.Gravity = 0
        task.wait(15)
        Workspace.Gravity = 196.2
        
    elseif name == "Gravedad Lunar" then
        Workspace.Gravity = 32.4
        task.wait(15)
        Workspace.Gravity = 196.2
        
    elseif name == "Super Velocidad" then
        humanoid.WalkSpeed = 300
        task.wait(10)
        humanoid.WalkSpeed = Config.WalkSpeed
        
    elseif name == "Cámara Loca" then
        task.spawn(function()
            for i = 1, 100 do
                Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(math.random(-10, 10)), math.rad(math.random(-10, 10)), 0)
                task.wait(0.05)
            end
        end)
        
    elseif name == "Pantalla Giratoria" then
        task.spawn(function()
            for i = 1, 200 do
                Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0, math.rad(5))
                task.wait(0.03)
            end
        end)
        
    elseif name == "Fuego en el Suelo" then
        for i = 1, 30 do
            task.spawn(function()
                local fire = Instance.new("Part")
                fire.Name = "AdminFire"
                fire.Size = Vector3.new(5, 0.2, 5)
                fire.Color = Color3.fromRGB(255, 100, 0)
                fire.Material = Enum.Material.Neon
                fire.Position = root.Position + Vector3.new(math.random(-40, 40), -2, math.random(-40, 40))
                fire.Parent = Workspace
                fire.CanCollide = false
                local fireEffect = Instance.new("Fire")
                fireEffect.Parent = fire
                task.wait(5)
                fire:Destroy()
            end)
        end
        
    elseif name == "Hielo Resbaladizo" then
        local ice = Instance.new("Part")
        ice.Name = "AdminIce"
        ice.Size = Vector3.new(200, 1, 200)
        ice.Color = Color3.fromRGB(150, 220, 255)
        ice.Material = Enum.Material.Ice
        ice.Position = root.Position + Vector3.new(0, -3, 0)
        ice.Parent = Workspace
        ice.CanCollide = true
        task.wait(15)
        ice:Destroy()
        
    elseif name == "Modo Gigante" then
        character:ScaleTo(3)
        
    elseif name == "Modo Enano" then
        character:ScaleTo(0.3)
        
    elseif name == "Duplicar Jugadores" then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                plr.Character.Archivable = true
                local clone = plr.Character:Clone()
                clone.Parent = Workspace
                clone:SetPrimaryPartCFrame(plr.Character.PrimaryPart.CFrame + Vector3.new(3, 0, 0))
            end
        end
        
    elseif name == "Modo Fantasma" then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.7
                part.CanCollide = false
            end
        end
        task.wait(10)
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
        
    elseif name == "Invisibilidad" then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            end
        end
        task.wait(10)
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        
    elseif name == "Confusión" then
        task.spawn(function()
            for i = 1, 100 do
                Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(math.random(-20, 20)), math.rad(math.random(-20, 20)), math.rad(math.random(-20, 20)))
                task.wait(0.05)
            end
        end)
        
    elseif name == "Ralentización" then
        humanoid.WalkSpeed = 5
        task.wait(10)
        humanoid.WalkSpeed = Config.WalkSpeed
    end
end

-- =========================

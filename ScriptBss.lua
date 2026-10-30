-- // Limpiar UI anterior si ya estaba abierta //
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("BSSSolaraHub") then
    CoreGui.BSSSolaraHub:Destroy()
end

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- // Crear la Interfaz (ScreenGui) //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BSSSolaraHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 275)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -137)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastrar la ventana por la pantalla
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "🐝 BSS Solara Hub"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Etiqueta de Estado
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 0, 38)
Status.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Status.Text = "Estado: Detenido"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.Parent = MainFrame
local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = Status

-- Función para crear botones estilizados
local function createButton(posY, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize, btn.Font = 13, Enum.Font.GothamSemibold
    btn.Parent = MainFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local FarmBtn = createButton(73, "Auto Farm & Click: OFF")
local MoveBtn = createButton(112, "Movimiento Circular: OFF")
local SprinklerBtn = createButton(151, "Colocar Aspersor (Tecla 1)")
local CloseBtn = createButton(220, "Cerrar / Destruir UI")

-- Colores especiales para botones de acción única
SprinklerBtn.BackgroundColor3 = Color3.fromRGB(160, 100, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)

-- Variables de Control
local farmActive = false
local moveActive = false
local centerPos = Vector3.new(0,0,0)
local centerSet = false

-- // Hilo de Auto-Farm (Herramienta + Clic Izquierdo) //
task.spawn(function()
    while true do
        task.wait(0.2)
        if farmActive then
            local character = LocalPlayer.Character
            if character then
                local tool = character:FindFirstChildOfClass("Tool")
                if not tool then
                    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if backpack then
                        tool = backpack:FindFirstChildOfClass("Tool")
                        if tool then tool.Parent = character end
                    end
                end
                if tool then
                    pcall(function() tool:Activate() end)
                end
                -- Clic izquierdo
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end
    end
end)

-- // Hilo de Movimiento Circular //
task.spawn(function()
    local angle = 0
    while true do
        task.wait(0.3)
        if moveActive then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local hrp = character.HumanoidRootPart
                local humanoid = character.Humanoid
                
                -- Si se activa, fija el centro donde esté parado el jugador en ese momento
                if not centerSet then
                    centerPos = hrp.Position
                    centerSet = true
                    Status.Text = "Estado: Farmeando (Centro Fijado)"
                end

                angle = angle + 0.3
                local offsetX = math.cos(angle) * 15
                local offsetZ = math.sin(angle) * 15
                local targetPos = Vector3.new(centerPos.X + offsetX, centerPos.Y, centerPos.Z + offsetZ)

                humanoid:MoveTo(targetPos)
            end
        end
    end
end)

-- // Conexiones de los Botones //
FarmBtn.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    if farmActive then
        FarmBtn.Text = "Auto Farm & Click: ON"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
    else
        FarmBtn.Text = "Auto Farm & Click: OFF"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
end)

MoveBtn.MouseButton1Click:Connect(function()
    moveActive = not moveActive
    if moveActive then
        MoveBtn.Text = "Movimiento Circular: ON"
        MoveBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
        centerSet = false -- Vuelve a capturar el centro actual
    else
        MoveBtn.Text = "Movimiento Circular: OFF"
        MoveBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        Status.Text = "Estado: Detenido"
    end
end)

SprinklerBtn.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
    Status.Text = "Estado: Aspersor colocado (Tecla 1)"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("[BSS Solara] UI cargada con éxito.")
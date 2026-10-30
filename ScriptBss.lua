-- ============================================================================
-- NATRO MACRO COMPLETE SCRIPT (LUA - SOLARA / EXECUTORS)
-- Bee Swarm Simulator (Roblox)
-- ============================================================================

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end)

local NatroConfig = {
    Field = "Dandelion Field",
    ConvertAtPollenPercent = 100,
    AutoSprinkler = true
}

local NatroState = {
    CurrentState = "CLAIM_HIVE",
    HiveNumber = nil,
    HivePosition = nil
}

-- Coordenadas exactas de las 6 colmenas
local HiveCoordinates = {
    Vector3.new(-187.24, 5.94, 330.23), -- Colmena 1
    Vector3.new(-148.78, 5.94, 330.25), -- Colmena 2
    Vector3.new(-113.71, 5.94, 330.30), -- Colmena 3
    Vector3.new(-76.91,  5.94, 329.38), -- Colmena 4
    Vector3.new(-41.15,  5.94, 330.94), -- Colmena 5
    Vector3.new(-4.38,   5.94, 331.48)  -- Colmena 6
}

-- Rutas de salida hacia fields específicas según el número de colmena
local FieldRoutes = {
    [1] = {
        ["Dandelion Field"] = {
            Vector3.new(-187.26, 5.94, 330.80),
            Vector3.new(-187.91, 4.01, 297.81),
            Vector3.new(-117.52, 4.01, 296.43),
            Vector3.new(-118.32, 4.70, 256.09),
            Vector3.new(-114.45, 4.70, 256.01),
            Vector3.new(-112.48, 4.01, 248.08),
            Vector3.new(-107.58, 4.42, 236.82),
            Vector3.new(-37.22, 4.01, 235.43),
            Vector3.new(-37.60, 4.01, 216.37)
        }
    }
}

local StatsReader = {}
function StatsReader.GetPollen()
    local coreStats = LocalPlayer:FindFirstChild("CoreStats")
    if coreStats and coreStats:FindFirstChild("Pollen") then
        return coreStats.Pollen.Value
    end
    return 0
end

function StatsReader.GetCapacity()
    local coreStats = LocalPlayer:FindFirstChild("CoreStats")
    if coreStats and coreStats:FindFirstChild("Capacity") then
        return coreStats.Capacity.Value
    end
    return 1
end

function StatsReader.IsBackpackFull()
    local pollen = StatsReader.GetPollen()
    local capacity = StatsReader.GetCapacity()
    if capacity <= 0 then return false end
    return ((pollen / capacity) * 100) >= NatroConfig.ConvertAtPollenPercent
end

local Navigation = {}
function Navigation.WalkTo(targetPos, timeout)
    timeout = timeout or 15
    Humanoid:MoveTo(targetPos)
    local reached = false
    local conn
    conn = Humanoid.MoveToFinished:Connect(function()
        reached = true
    end)
    
    local startTime = tick()
    while not reached and (tick() - startTime) < timeout do
        if (RootPart.Position - targetPos).Magnitude < 4 then
            break
        end
        if Humanoid.WalkToPoint ~= targetPos then
            Humanoid:MoveTo(targetPos)
        end
        task.wait(0.1)
    end
    if conn then conn:Disconnect() end
end

local HiveManager = {}
function HiveManager.ClaimHive()
    task.wait((LocalPlayer.UserId % 5) * 0.4) -- Jitter multicuenta
    
    for index, pos in ipairs(HiveCoordinates) do
        Navigation.WalkTo(pos, 8)
        task.wait(0.6)
        
        local activateBtn = LocalPlayer.PlayerGui:FindFirstChild("ActivateButton", true)
        if activateBtn and activateBtn:FindFirstChild("TextBox") then
            local text = activateBtn.TextBox.Text:lower()
            
            -- Opciones de interfaz: Claim Hive o textos de colmena propia
            if string.find(text, "claim hive") then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(1.5)
                
                NatroState.HiveNumber = index
                NatroState.HivePosition = RootPart.CFrame
                print("[Natro] ¡Colmena #" .. index .. " reclamada con éxito!")
                return true
                
            elseif string.find(text, "to make honey") or string.find(text, "make honey") then
                NatroState.HiveNumber = index
                NatroState.HivePosition = RootPart.CFrame
                print("[Natro] Esta colmena ya nos pertenece (Colmena #" .. index .. ").")
                return true
            end
        end
    end
    return false
end

-- Bucle principal del Macro
task.spawn(function()
    print("[NatroMacro] Iniciando sistema...")
    while true do
        task.wait(0.2)
        
        if NatroState.CurrentState == "CLAIM_HIVE" then
            local success = HiveManager.ClaimHive()
            if success then
                NatroState.CurrentState = "WALK_TO_FIELD"
            else
                task.wait(2)
            end
            
        elseif NatroState.CurrentState == "WALK_TO_FIELD" then
            local route = FieldRoutes[NatroState.HiveNumber] and FieldRoutes[NatroState.HiveNumber][NatroConfig.Field]
            if route then
                for _, waypoint in ipairs(route) do
                    Navigation.WalkTo(waypoint, 10)
                end
                print("[Natro] ¡Llegada al campo completada!")
                NatroState.CurrentState = "FARMING"
            else
                print("[Natro] No hay ruta configurada para esta colmena hacia este campo.")
                task.wait(5)
            end
            
        elseif NatroState.CurrentState == "FARMING" then
            -- Simulación de farmeo y uso de herramienta
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
            
            if StatsReader.IsBackpackFull() then
                NatroState.CurrentState = "RETURN_TO_HIVE"
            end
            task.wait(0.1)
            
        elseif NatroState.CurrentState == "RETURN_TO_HIVE" then
            if NatroState.HivePosition then
                Navigation.WalkTo(NatroState.HivePosition.Position, 25)
            end
            NatroState.CurrentState = "CONVERTING"
            
        elseif NatroState.CurrentState == "CONVERTING" then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            
            while StatsReader.GetPollen() > 0 do
                task.wait(1)
            end
            
            task.wait(2)
            NatroState.CurrentState = "WALK_TO_FIELD"
        end
    end
end)

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Las 6 coordenadas exactas de las colmenas que registraste
local HiveCoordinates = {
    Vector3.new(-187.24, 5.94, 330.23), -- Colmena 1[cite: 2]
    Vector3.new(-148.78, 5.94, 330.25), -- Colmena 2[cite: 2]
    Vector3.new(-113.71, 5.94, 330.30), -- Colmena 3[cite: 2]
    Vector3.new(-76.91,  5.94, 329.38), -- Colmena 4[cite: 2]
    Vector3.new(-41.15,  5.94, 330.94), -- Colmena 5[cite: 2]
    Vector3.new(-4.38,   5.94, 331.48)  -- Colmena 6[cite: 2]
}

local HiveManager = {}
HiveManager.MyHivePosition = nil
HiveManager.IsClaimed = false

-- Función de movimiento seguro hacia la colmena
local function walkTo(targetPos)
    Humanoid:MoveTo(targetPos)
    local reached = false
    local conn
    conn = Humanoid.MoveToFinished:Connect(function()
        reached = true
    end)
    
    local start = tick()
    while not reached and (tick() - start) < 10 do
        if (RootPart.Position - targetPos).Magnitude < 4 then
            break
        end
        task.wait(0.1)
    end
    if conn then conn:Disconnect() end
end

-- Función de escaneo, validación y reclamo estricto
function HiveManager.FindAndClaimHive()
    -- Jitter de tiempo para evitar conflictos en multicuenta
    task.wait((LocalPlayer.UserId % 5) * 0.5)
    
    for index, pos in ipairs(HiveCoordinates) do
        print("[HiveManager] Caminando hacia la colmena #" .. index)
        walkTo(pos)
        task.wait(0.6) -- Pausa corta para estabilizar la UI al llegar
        
        -- Verificar el texto en la interfaz (ActivateButton / TextBox)
        local activateBtn = LocalPlayer.PlayerGui:FindFirstChild("ActivateButton", true)
        if activateBtn and activateBtn:FindFirstChild("TextBox") then
            local uiText = activateBtn.TextBox.Text:lower()
            
            -- CASO 1: Colmena libre ("Claim Hive")[cite: 3]
            if string.find(uiText, "claim hive") then
                print("[HiveManager] ¡Colmena #" .. index .. " libre! Reclamando...")
                
                -- Simular pulsación de la tecla 'E'
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(1.5)
                
                -- Guardar posición, fijar estado y quedarse quieto en este punto exacto
                HiveManager.MyHivePosition = RootPart.CFrame
                HiveManager.IsClaimed = true
                print("[HiveManager] ¡Colmena reclamada con éxito! Quedándose quieto en el punto y pasando al siguiente paso.")
                return true
                
            -- CASO 2: La colmena ya nos pertenece ("To Make Honey...")[cite: 5]
            elseif string.find(uiText, "to make honey") then
                print("[HiveManager] Esta colmena ya nos pertenece. Quedándose en el punto.")
                HiveManager.MyHivePosition = RootPart.CFrame
                HiveManager.IsClaimed = true
                return true
                
            -- CASO 3: Ocupada por otro jugador ("Send Trade Request to...")[cite: 4]
            elseif string.find(uiText, "send trade request") then
                print("[HiveManager] Colmena #" .. index .. " ocupada. Saltando a la siguiente...")
            end
        end
    end
    
    print("[HiveManager] No se encontró ninguna colmena disponible en esta pasada.")
    return false
end

-- Ejecución inicial del reclamo
local success = HiveManager.FindAndClaimHive()
if success then
    -- AQUÍ PROSIGUE CON EL SIGUIENTE PASO (ej. ir al campo de farmeo)
    print(">>> Siguiente paso: Iniciando trayecto hacia el campo de farmeo...")
end

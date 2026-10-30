print("[BSS Solara] Iniciando script multicuenta con desincronización...")

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Generar una semilla aleatoria basada en el tiempo actual para cada cliente
math.randomseed(os.time() + LocalPlayer.UserId)

-- Función auxiliar para presionar teclas
local function pressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- // 1. REINICIO INICIAL //
print("[BSS Solara] Reiniciando personaje...")
pressKey(Enum.KeyCode.Escape)
task.wait(0.4)
pressKey(Enum.KeyCode.R)
task.wait(0.4)
pressKey(Enum.KeyCode.Return)

task.wait(3.5)

-- // 2. LISTA DE COLMENAS //
local listaColmenas = {
    Vector3.new(-183.75, 5.94, 330.39),
    Vector3.new(-150.09, 5.94, 331.43),
    Vector3.new(-113.49, 5.94, 330.35),
    Vector3.new(-74.88, 5.94, 329.33),
    Vector3.new(-40.20, 5.94, 329.98),
    Vector3.new(-3.53, 5.94, 331.19)
}

-- Función para obtener el texto actual del botón de interacción
local function obtenerTextoBoton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local screenGui = playerGui:FindFirstChild("ScreenGui")
        if screenGui then
            local activateButton = screenGui:FindFirstChild("ActivateButton")
            if activateButton then
                local textBox = activateButton:FindFirstChild("TextBox")
                if textBox then
                    return string.lower(textBox.Text)
                end
            end
        end
    end
    return ""
end

-- // 3. BUCLE PRINCIPAL //
for indice, destino in ipairs(listaColmenas) do
    print("[BSS] Moviéndose a la colmena #" .. indice)
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
        local humanoid = character.Humanoid
        
        humanoid:MoveTo(destino)
        
        -- Esperar llegada al punto
        local startTime = tick()
        repeat
            task.wait(0.1)
        until (character.HumanoidRootPart.Position - destino).Magnitude < 5 or (tick() - startTime) > 7
        
        -- Retardo aleatorio para desincronizar el reclamo entre múltiples cuentas
        local tiempoEspera = math.random(20, 90) / 100 -- Entre 0.2s y 0.9s
        task.wait(tiempoEspera)
        
        local textoActual = obtenerTextoBoton()
        print("[BSS Debug] Texto detectado: " .. textoActual)
        
        -- Si dice estrictamente "claim hive" y NO tiene "send trade"
        if string.find(textoActual, "claim hive") and not string.find(textoActual, "send trade") then
            print("✅ Tentativa de reclamo en Colmena #" .. indice)
            pressKey(Enum.KeyCode.E)
            
            -- Esperar a que el servidor actualice el reclamo
            task.wait(1.2)
            
            -- Re-evaluar estado tras presionar E
            local textoConfirmacion = obtenerTextoBoton()
            
            if string.find(textoConfirmacion, "send trade") then
                print("❌ Pérdida de conflicto: La colmena fue tomada por otra cuenta. Saltando...")
            else
                print("🎉 ¡Colmena #" .. indice .. " reclamada y confirmada!")
                break -- Salir del bucle con éxito
            end
        else
            print("❌ ELSE: Colmena #" .. indice .. " ocupada o con trade. Pasando a la siguiente...")
        end
    end
    
    task.wait(0.2)
end

print("[BSS] Proceso de selección completado.")

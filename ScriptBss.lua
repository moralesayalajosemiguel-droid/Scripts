print("[BSS Solara] Iniciando script multicuenta ultra-robusto...")

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

math.randomseed(os.time() + LocalPlayer.UserId)

-- Función auxiliar para presionar teclas de forma segura
local function pressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- // 1. PASO INICIAL: Reiniciar personaje (ESC -> R -> ENTER) //
print("[BSS Solara] Reiniciando personaje...")
pressKey(Enum.KeyCode.Escape)
task.wait(0.4)
pressKey(Enum.KeyCode.R)
task.wait(0.4)
pressKey(Enum.KeyCode.Return)

task.wait(3.5)

-- // 2. LISTA DE LAS 6 COLMENAS //
local listaColmenas = {
    Vector3.new(-183.75, 5.94, 330.39), -- Colmena 1
    Vector3.new(-150.09, 5.94, 331.43), -- Colmena 2
    Vector3.new(-113.49, 5.94, 330.35), -- Colmena 3
    Vector3.new(-74.88, 5.94, 329.33),  -- Colmena 4
    Vector3.new(-40.20, 5.94, 329.98),  -- Colmena 5
    Vector3.new(-3.53, 5.94, 331.19)    -- Colmena 6
}

-- Función para leer el texto del botón de la interfaz
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

-- // 3. BUCLE DE RECORRIDO Y VALIDACIÓN //
for indice, destino in ipairs(listaColmenas) do
    print("[BSS] Moviéndose a la colmena #" .. indice)
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
        local humanoid = character.Humanoid
        
        humanoid:MoveTo(destino)
        
        -- Esperar a que el personaje llegue al destino (con límite de 7 segundos)
        local startTime = tick()
        repeat
            task.wait(0.1)
        until (character.HumanoidRootPart.Position - destino).Magnitude < 4 or (tick() - startTime) > 7
        
        -- Desincronización aleatoria para evitar colisiones idénticas en milisegundos exactos
        task.wait(math.random(10, 50) / 100)
        
        -- ESPERA ACTIVA: Dar un margen de hasta 1.5 segundos para que la UI cargue el texto correctamente
        local textoEncontrado = ""
        local tiempoEsperaTexto = tick()
        repeat
            textoEncontrado = obtenerTextoBoton()
            if string.find(textoEncontrado, "claim hive") or string.find(textoEncontrado, "send trade") then
                break
            end
            task.wait(0.1)
        until (tick() - tiempoEsperaTexto) > 1.5
        
        print("[BSS Debug] Colmena #" .. indice | " - Texto detectado: " .. textoEncontrado)
        
        -- Verificar si está disponible de verdad
        if string.find(textoEncontrado, "claim hive") and not string.find(textoEncontrado, "send trade") then
            print("✅ IF: ¡Colmena #" .. indice .. " libre! Intentando reclamar...")
            
            -- Enviar múltiples pulsaciones rápidas de 'E' para asegurar el slot
            for i = 1, 3 do
                pressKey(Enum.KeyCode.E)
                task.wait(0.1)
            end
            
            task.wait(1.0) -- Esperar respuesta del servidor
            
            -- Comprobación post-intento
            local textoDespues = obtenerTextoBoton()
            if string.find(textoDespues, "send trade") then
                print("❌ Conflicto: Otra cuenta tomó la colmena (Send Trade detectado). Saltando...")
            else
                print("🎉 ¡Colmena #" .. indice .. " reclamada con éxito! Finalizando script.")
                break -- Salir del bucle con éxito
            end
        else
            -- ELSE: Si está ocupada o no cargó como libre, pasa a la siguiente
            print("❌ ELSE: Colmena #" .. indice .. " ocupada o no disponible. Saltando...")
        end
    end
    
    task.wait(0.3)
end

print("[BSS] Proceso de selección de colmena completado.")

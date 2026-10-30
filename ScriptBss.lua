print("[BSS Solara] Iniciando script de búsqueda (6 colmenas)...")

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

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

-- Esperar a que el personaje muera y reaparezca
task.wait(3.5)

-- // 2. LISTA COMPLETA DE LAS 6 COLMENAS //
local listaColmenas = {
    Vector3.new(-183.75, 5.94, 330.39), -- Colmena 1 (La primera original)
    Vector3.new(-150.09, 5.94, 331.43), -- Colmena 2[cite: 12]
    Vector3.new(-113.49, 5.94, 330.35), -- Colmena 3[cite: 12]
    Vector3.new(-74.88, 5.94, 329.33),  -- Colmena 4[cite: 12]
    Vector3.new(-40.20, 5.94, 329.98),  -- Colmena 5[cite: 12]
    Vector3.new(-3.53, 5.94, 331.19)    -- Colmena 6[cite: 12]
}

-- Función para verificar si la colmena actual está libre mediante el texto de la pantalla
local function esColmenaLibre()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local screenGui = playerGui:FindFirstChild("ScreenGui")
        if screenGui then
            local activateButton = screenGui:FindFirstChild("ActivateButton")
            if activateButton then
                local textBox = activateButton:FindFirstChild("TextBox")
                if textBox then
                    local textoActual = string.lower(textBox.Text)
                    print("[BSS Debug] Texto detectado: " .. textBox.Text)
                    
                    if string.find(textoActual, "claim hive") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- // 3. BUCLE DE RECORRIDO Y VALIDACIÓN //
for indice, destino in ipairs(listaColmenas) do
    print("[BSS] Moviéndose a la colmena #" .. indice)
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
        local humanoid = character.Humanoid
        
        -- Caminar hacia la colmena actual
        humanoid:MoveTo(destino)
        
        -- Esperar a que llegue (con límite de 7 segundos)
        local startTime = tick()
        repeat
            task.wait(0.1)
        until (character.HumanoidRootPart.Position - destino).Magnitude < 5 or (tick() - startTime) > 7
        
        task.wait(0.6) -- Pausa breve para que cargue la interfaz visual
        
        -- BLOQUE IF / ELSE
        if esColmenaLibre() then
            print("✅ IF: ¡Colmena #" .. indice .. " libre detectada!")
            pressKey(Enum.KeyCode.E) -- Reclamar con la E
            print("🎉 ¡Colmena reclamada con éxito! Finalizando script.")
            break -- Rompe el bucle porque ya conseguimos colmena
        else
            -- ELSE: Si está ocupada, avanza a la siguiente
            print("❌ ELSE: Colmena #" .. indice .. " ocupada. Saltando a la siguiente...")
        end
    end
    
    task.wait(0.3)
end

print("[BSS] Proceso de selección de colmena completado.")

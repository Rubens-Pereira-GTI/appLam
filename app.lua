-- all_in_one_detector.lua
-- Injetado via [SCRIPT_...] nas Extra Options

local pneusFora = 3
local isCutting = false
local playerStats = {}
local wheelsOut


function script.init()
    ac.debug("🎮 Detector Iniciado")
    SIM = ac.getSim()
    CAR = ac.getCar(SIM.focusedCar)
    
    -- ✅ Escuta eventos de OUTROS jogadores
    ac.onSharedEvent("playerCutDetected", function(data)
        onPlayerCut(data)
    end)
end

function script.update(dt)    
    checkTrackLimits()
    
end

function checkTrackLimits()
    wheelsOut = CAR.wheelsOutside
    if wheelsOut > pneusFora and not isCutting then
        isCutting = true
        
        local dados = {
            wheels = wheelsOut,
            progress = CAR.splinePosition,
            speed = CAR.speed * 3.6,
            playerName = ac.getPlayerName()  -- ✅ Nome do jogador
        }
        
        -- Envia para TODOS (incluindo "servidor")
        ac.broadcastSharedEvent("playerCutDetected", dados)
        
        -- Também processa localmente
        onPlayerCut(dados)
    elseif wheelsOut <= pneusFora then
        isCutting = false
    end
    
end

function onPlayerCut(data)
    local playerName = data.playerName or "Desconhecido"
    
    if not playerStats[playerName] then
        playerStats[playerName] = {cuts = 0}
    end
    
    playerStats[playerName].cuts = playerStats[playerName].cuts + 1
    
    ac.warn("🔴 " .. playerName .. " cortou! Total: " .. 
            playerStats[playerName].cuts .. " cortes")
end
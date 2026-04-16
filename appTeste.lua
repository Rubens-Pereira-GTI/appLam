

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))



function script.update(dt)

    -- Cores entre 0 e 1 (para manter a tonalidade da cor)
    local r = math.random() -- Gera um decimal entre 0 e 1
    local g = math.random()
    local b = math.random()
    -- Brilho (Neon) entre 1 e 10 (para não cegar o jogador)
    local intensidade = math.random(1, 10)
   
    if CAR.wheelsOutside > 3 then
           
        ac.debug("Wheels Outside", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(r*intensidade, g*intensidade, b*intensidade, 1))
    end
end


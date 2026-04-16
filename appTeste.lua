

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))



function script.update(dt)
   
    if CAR.wheelsOutside > 3 then
        local r = math.random(0, 255)
        local g = math.random(0, 255)
        local b = math.random(0, 255)
    
        ac.debug("Wheels Outside", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(r, g, b, 1))
    end
end


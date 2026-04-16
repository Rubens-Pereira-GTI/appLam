

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))



function script.update(dt)    
   
    if CAR.wheelsOutside > 3 then
           
        ac.debug("Wheels Outside", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(5, 0, 0, 1))
    elseif CAR.wheelsOutside == 0 then
        ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))
    end
end


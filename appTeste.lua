

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

function script.update(dt)
    ac.setDriverChatNameColor(CAR, rgbm(1, 0, 0, 1))
    
end

